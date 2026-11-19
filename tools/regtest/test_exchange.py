"""Exercise the dummy exchange settlement against fake chain nodes."""

from decimal import Decimal
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).parent))
import exchange  # noqa: E402


class FakeNode:
    """Records wallet calls; tests choose what the chain reports."""

    def __init__(self, name):
        self.name = name
        self.sent = []
        self.received = {}
        self.confirmations = 0
        self.addresses = 0

    def call(self, method, **params):
        if method == "getnewaddress":
            self.addresses += 1
            return f"{self.name}-payin-{self.addresses}"
        if method == "sendtoaddress":
            self.sent.append((params["address"], Decimal(str(params["amount"]))))
            return f"{self.name}-tx-{len(self.sent)}"
        if method == "gettransaction":
            return {"confirmations": self.confirmations}
        if method == "getreceivedbyaddress":
            return float(self.received.get(params["address"], 0))
        raise AssertionError(method)


class AssetMapNode(FakeNode):
    """Elements answers getreceivedbyaddress with an amount per asset label."""

    def call(self, method, **params):
        value = super().call(method, **params)
        return {"bitcoin": value} if method == "getreceivedbyaddress" else value


class SettlementTest(unittest.TestCase):
    def setUp(self):
        self.nodes = {"bitcoin": FakeNode("bitcoin"), "liquid": FakeNode("liquid")}
        self.exchange = exchange.Exchange(nodes=self.nodes, btc_price=Decimal(100000))

    def order(self, order_id):
        return self.exchange.dispatch("getOrderSummary", {"orderId": order_id})

    def test_default_scenario_settles_for_real(self):
        self.assertEqual(self.exchange.scenario, "settle")

    def test_buy_pays_the_user_address_then_completes_after_confirmation(self):
        created = self.exchange.dispatch("createOrderBuy", {
            "fiatCurrency": "CAD", "network": "liquid", "isOwner": True,
            "address": "user-liquid", "fiatAmount": 100})
        self.assertEqual(self.nodes["liquid"].sent, [])
        self.exchange.dispatch("confirmOrderSummary", {"orderId": created["orderId"]})
        self.assertEqual(self.nodes["liquid"].sent, [("user-liquid", Decimal("0.00099"))])
        self.assertEqual(self.nodes["bitcoin"].sent, [])
        pending = self.order(created["orderId"])
        self.assertEqual(pending["liquidTransactionId"], "liquid-tx-1")
        self.assertNotEqual(pending["orderStatus"], "Completed")
        self.nodes["liquid"].confirmations = 1
        self.assertEqual(self.order(created["orderId"])["orderStatus"], "Completed")

    def test_buy_reads_the_address_of_a_bip21_uri(self):
        created = self.exchange.dispatch("createOrderBuy", {
            "fiatCurrency": "CAD", "network": "bitcoin", "isOwner": True,
            "bip21URI": "bitcoin:user-btc?amount=0.001", "bitcoinAmount": 0.001})
        self.exchange.dispatch("confirmOrderSummary", {"orderId": created["orderId"]})
        self.assertEqual(self.nodes["bitcoin"].sent[0][0], "user-btc")

    def test_sell_waits_for_the_payin_then_credits_the_fiat_balance(self):
        created = self.exchange.dispatch("sellToBalance", {
            "fiatCurrency": "CAD", "bitcoinNetwork": "bitcoin", "bitcoinAmount": 0.001})
        address = created["bitcoinAddress"]
        self.assertEqual(address, "bitcoin-payin-1")
        self.assertEqual(self.order(created["orderId"])["payinStatus"], "Awaiting payment")
        self.nodes["bitcoin"].received[address] = Decimal("0.001")
        self.nodes["bitcoin"].confirmations = 1
        done = self.order(created["orderId"])
        self.assertEqual(done["orderStatus"], "Completed")
        self.assertEqual(done["payinStatus"], "Completed")
        summary = self.exchange.dispatch("getUserSummary", {})
        self.assertEqual(
            {b["currencyCode"]: b["amount"] for b in summary["balances"]}["CAD"], 10099)
        self.order(created["orderId"])
        summary = self.exchange.dispatch("getUserSummary", {})
        self.assertEqual(summary["balances"][0]["amount"], 10099, "credited once")

    def test_liquid_payin_is_read_from_the_policy_asset_amount(self):
        self.nodes["liquid"] = AssetMapNode("liquid")
        self.exchange.nodes = self.nodes
        created = self.exchange.dispatch("sellToBalance", {
            "fiatCurrency": "CAD", "bitcoinNetwork": "liquid", "bitcoinAmount": 0.001})
        self.assertEqual(self.order(created["orderId"])["payinStatus"], "Awaiting payment")
        self.nodes["liquid"].received[created["liquidAddress"]] = Decimal("0.001")
        self.nodes["liquid"].confirmations = 1
        self.assertEqual(self.order(created["orderId"])["orderStatus"], "Completed")

    def test_pay_a_recipient_is_a_fiat_payment_that_credits_no_balance(self):
        created = self.exchange.dispatch("sellToRecipient", {
            "recipientId": "r", "bitcoinNetwork": "liquid", "bitcoinAmount": 0.002,
            "paymentDescription": "rent"})
        self.assertEqual(created["orderType"], "Fiat Payment")
        self.assertEqual(created["payoutMethod"], "Interac e-Transfer (CAD)")
        self.assertEqual(created["paymentDescription"], "rent")
        self.assertEqual(created["liquidAddress"], "liquid-payin-1")
        self.nodes["liquid"].received["liquid-payin-1"] = Decimal("0.002")
        self.nodes["liquid"].confirmations = 1
        self.assertEqual(self.order(created["orderId"])["orderStatus"], "Completed")
        balances = {b["currencyCode"]: b["amount"]
                    for b in self.exchange.dispatch("getUserSummary", {})["balances"]}
        self.assertEqual(balances["CAD"], 10000)

    def test_swap_pays_out_on_the_other_network_after_the_payin(self):
        created = self.exchange.dispatch("createOrderSwap", {
            "amount": 0.01, "isInAmountFixed": True, "inNetwork": "bitcoin",
            "outNetwork": "liquid", "destinationAddress": "user-liquid"})
        address = created["bitcoinAddress"]
        self.order(created["orderId"])
        self.assertEqual(self.nodes["liquid"].sent, [])
        self.nodes["bitcoin"].received[address] = Decimal("0.01")
        self.nodes["bitcoin"].confirmations = 1
        self.order(created["orderId"])
        self.assertEqual(self.nodes["liquid"].sent, [("user-liquid", Decimal("0.0099"))])
        self.order(created["orderId"])
        self.assertEqual(len(self.nodes["liquid"].sent), 1, "paid out once")
        self.nodes["liquid"].confirmations = 1
        done = self.order(created["orderId"])
        self.assertEqual(done["orderStatus"], "Completed")
        self.assertEqual(done["liquidTransactionId"], "liquid-tx-1")

    def test_lightning_is_refused_instead_of_faked(self):
        with self.assertRaises(ValueError):
            self.exchange.dispatch("createOrderSwap", {
                "amount": 0.01, "isInAmountFixed": True, "inNetwork": "lightning",
                "outNetwork": "liquid", "destinationAddress": "x"})

    def test_rate_follows_the_configured_price(self):
        rate = self.exchange.dispatch("getRate", {"element": {"fromCurrency": "BTC", "toCurrency": "CAD"}})
        self.assertEqual(rate["element"]["indexPrice"], 10000000)
        usd = self.exchange.dispatch("getRate", {"element": {"fromCurrency": "BTC", "toCurrency": "USD"}})
        self.assertLess(usd["element"]["indexPrice"], 10000000)

    def test_order_rate_is_the_plain_price_not_the_scaled_index(self):
        created = self.exchange.dispatch("createOrderBuy", {
            "network": "bitcoin", "address": "a", "fiatAmount": 100})
        self.assertEqual(created["exchangeRateAmount"], 100000)

    def test_fiat_recipients_offer_one_demo_interac_recipient(self):
        listed = self.exchange.dispatch("listRecipientsFiat", {
            "paginator": {"page": 1, "pageSize": 50}})
        self.assertEqual(listed["totalElements"], 1)
        element = listed["elements"][0]
        self.assertEqual(element["recipientTypeFiat"], "INTERAC_EMAIL_CAD")
        for key in ("recipientId", "userId", "userNbr", "isArchived", "createdAt", "updatedAt"):
            self.assertIn(key, element)
        other = self.exchange.dispatch("listRecipientsFiat", {
            "filters": {"recipientTypeFiat": ["SEPA_EUR"]}})
        self.assertEqual(other["totalElements"], 0)

    def test_legacy_scenarios_never_touch_the_nodes(self):
        self.exchange.scenario = "completed"
        created = self.exchange.dispatch("createOrderBuy", {"address": "a", "fiatAmount": 10})
        self.assertEqual(self.order(created["orderId"])["orderStatus"], "Completed")
        self.assertEqual(self.nodes["bitcoin"].sent + self.nodes["liquid"].sent, [])


if __name__ == "__main__":
    unittest.main()
