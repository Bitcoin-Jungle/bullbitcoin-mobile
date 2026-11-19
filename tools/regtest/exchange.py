#!/usr/bin/env python3
"""Disposable BULL API simulator. No trading, real credentials or settlement."""

import argparse
from datetime import datetime, timedelta, timezone
from decimal import Decimal, InvalidOperation
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
import signal
import sys
from urllib.parse import parse_qs, urlparse
import urllib.request
from uuid import uuid4
import base64

SCENARIOS = ("settle", "pending", "completed", "expired", "rate-limited", "unavailable")
FEE = Decimal("0.99")
USD_PER_CAD = Decimal("0.72")
SAT = Decimal("0.00000001")
NETWORKS = {"bitcoin": "BTC", "liquid": "LBTC"}


def received_amount(node, address, minconf):
    """Elements answers with an amount per asset label; Bitcoin with a number."""
    value = node.call("getreceivedbyaddress", address=address, minconf=minconf)
    if isinstance(value, dict):
        value = value.get("bitcoin", 0)
    return Decimal(str(value))


class Node:
    """Wallet JSON-RPC of a regtest bitcoind or elementsd (public dev credentials)."""

    def __init__(self, url, wallet="bull-regtest", user="admin1", password="123"):
        self.url = f"{url.rstrip('/')}/wallet/{wallet}"
        token = base64.b64encode(f"{user}:{password}".encode()).decode()
        self.headers = {"Authorization": f"Basic {token}", "Content-Type": "application/json"}

    def call(self, method, **params):
        body = json.dumps({"jsonrpc": "1.0", "id": "exchange", "method": method, "params": params}).encode()
        with urllib.request.urlopen(urllib.request.Request(self.url, body, self.headers), timeout=20) as response:
            answer = json.loads(response.read())
        if answer.get("error"):
            raise RuntimeError(f"{method}: {answer['error'].get('message')}")
        return answer["result"]


def default_nodes():
    return {"bitcoin": Node(os.environ.get("BITCOIND_URL", "http://bitcoin:18443")),
            "liquid": Node(os.environ.get("ELEMENTSD_URL", "http://liquid:18884"))}


def now():
    return datetime.now(timezone.utc).isoformat()


class Exchange:
    def __init__(self, nodes=None, btc_price=None):
        self.orders = {}
        self.scenario = "settle"
        self.preferences = {"currency": "CAD", "language": "en"}
        self.nodes = nodes if nodes is not None else default_nodes()
        self.btc_price = btc_price if btc_price is not None else Decimal(os.environ.get("DUMMY_BTC_PRICE", "150000"))
        self.balances = {"CAD": Decimal(10000), "USD": Decimal(10000)}
        self.jobs = {}

    def price(self, currency):
        return self.btc_price * (USD_PER_CAD if currency == "USD" else 1)

    def create_settled(self, method, params):
        """A real regtest order: fake fiat, real coins through the stack nodes."""
        kind = {"createOrderBuy": "buy", "createOrderSwap": "swap"}.get(method, "sell")
        fiat = params.get("fiatCurrency", self.preferences["currency"])
        if kind == "swap":
            incoming, outgoing = params["inNetwork"], params["outNetwork"]
            amount = Decimal(str(params["amount"]))
            if params.get("isInAmountFixed", True):
                payin, payout = amount, amount * FEE
            else:
                payin, payout = amount / FEE, amount
            destination = params["destinationAddress"]
        elif kind == "buy":
            incoming, outgoing = None, params["network"]
            destination = params.get("address") or urlparse(params["bip21URI"]).path
            if "fiatAmount" in params:
                fiat_amount = Decimal(str(params["fiatAmount"]))
                payin, payout = fiat_amount, fiat_amount / self.price(fiat) * FEE
            else:
                payout = Decimal(str(params["bitcoinAmount"]))
                payin = payout / FEE * self.price(fiat)
        else:
            incoming, outgoing, destination = params["bitcoinNetwork"], None, None
            if "bitcoinAmount" in params:
                payin = Decimal(str(params["bitcoinAmount"]))
            else:
                payin = Decimal(str(params["fiatAmount"])) / self.price(fiat) / FEE
            payout = payin * self.price(fiat) * FEE
        for network in (incoming, outgoing):
            if network is not None and network not in self.nodes:
                raise ValueError("Only bitcoin and liquid settle on regtest")
        payin_label = NETWORKS[incoming] if incoming else fiat
        payout_label = NETWORKS[outgoing] if outgoing else fiat
        labels = {"bitcoin": "Bitcoin On-Chain", "liquid": "Liquid Network"}
        order_id = str(uuid4())
        order = {"orderId": order_id, "orderNumber": len(self.orders) + 1,
                 "orderType": {"buy": "Buy Bitcoin", "swap": "Swap", "sell": "Sell Bitcoin"}[kind],
                 "payinAmount": float(payin.quantize(SAT) if incoming else payin.quantize(Decimal("0.01"))),
                 "payoutAmount": float(payout.quantize(SAT) if outgoing else payout.quantize(Decimal("0.01"))),
                 "payinCurrency": payin_label, "payoutCurrency": payout_label,
                 "payinMethod": labels[incoming] if incoming else f"{fiat} Balance",
                 "payoutMethod": labels[outgoing] if outgoing else f"{fiat} Balance",
                 "orderStatus": "Awaiting confirmation",
                 "payinStatus": "Awaiting payment" if incoming else "Not started",
                 "payoutStatus": "Not started", "message": {"code": "created"},
                 "createdAt": now(), "confirmationDeadline":
                     (datetime.now(timezone.utc) + timedelta(minutes=30)).isoformat(),
                 "exchangeRateAmount": int(self.price(fiat)), "exchangeRateCurrency": fiat}
        if incoming:
            order[f"{incoming}Address"] = self.nodes[incoming].call("getnewaddress")
        self.orders[order_id] = order
        self.jobs[order_id] = {"kind": kind, "incoming": incoming, "outgoing": outgoing, "fiat": fiat,
                               "payin": payin, "payout": payout, "destination": destination,
                               "confirmed": False, "paid_out": False, "credited": False}
        return order

    def confirmations(self, network, txid):
        return self.nodes[network].call("gettransaction", txid=txid).get("confirmations", 0)

    def settle(self, order, confirm=False):
        """Advance one order from what the chains report; every step runs once."""
        job = self.jobs[order["orderId"]]
        if confirm:
            job["confirmed"] = True
            order["orderStatus"] = "In progress"
        incoming, outgoing = job["incoming"], job["outgoing"]
        if incoming and order["payinStatus"] != "Completed":
            address = order[f"{incoming}Address"]
            node = self.nodes[incoming]
            received = received_amount(node, address, 1)
            if received >= job["payin"].quantize(SAT):
                order.update(payinStatus="Completed", orderStatus="In progress")
            elif received_amount(node, address, 0) >= job["payin"].quantize(SAT):
                order.update(payinStatus="In progress", orderStatus="In progress")
        if job["kind"] == "buy" and job["confirmed"] and not job["paid_out"]:
            order["payinStatus"] = "Completed"
        if outgoing and order["payinStatus"] == "Completed" and not job["paid_out"] and (job["kind"] != "buy" or job["confirmed"]):
            amount = job["payout"].quantize(SAT)
            txid = self.nodes[outgoing].call("sendtoaddress", address=job["destination"], amount=float(amount))
            job["paid_out"] = True
            job["payout_txid"] = txid
            order.update({f"{outgoing}TransactionId": txid, "payoutStatus": "In progress", "sentAt": now()})
        if outgoing and job["paid_out"] and order["payoutStatus"] != "Completed":
            if self.confirmations(outgoing, job["payout_txid"]) >= 1:
                order.update(payoutStatus="Completed")
        if not outgoing and order["payinStatus"] == "Completed" and not job["credited"]:
            job["credited"] = True
            self.balances[job["fiat"]] += job["payout"].quantize(Decimal("0.01"), rounding="ROUND_DOWN")
            order["payoutStatus"] = "Completed"
        if order["payinStatus"] in ("Completed", "Not started") and order["payoutStatus"] == "Completed":
            order.update(orderStatus="Completed", completedAt=now(), message={"code": "completed"})
        return order

    def dispatch(self, method, params):
        if method in ("getRate", "getIndexRateHistory"):
            window = params["element"]
            index = int(self.price(window.get("toCurrency", "CAD")) * 100)
            if method == "getRate":
                return {"element": {"indexPrice": index, "precision": 2}}
            end = datetime.fromtimestamp(int(window["toDate"]) / 1000, timezone.utc)
            return {"element": {"precision": 2, "rates": [
                {"periodStart": (end - timedelta(days=1)).isoformat(), "indexPrice": index * 999 // 1000},
                {"periodStart": end.isoformat(), "indexPrice": index},
            ]}}
        if method == "getUserSummary":
            return {"userNumber": 1, "userId": "dummy-user", "groups": ["KYC_IDENTITY_VERIFIED", "CONSENT_SCAM_WARNING"],
                    "profile": {"firstName": "Regtest", "lastName": "Developer"},
                    "email": "developer@example.invalid", "balances": [
                        {"amount": int(amount), "currencyCode": code}
                        for code, amount in self.balances.items()],
                    "dca": {"isActive": False}, "autoBuy": {"isActive": False, "addresses": {}},
                    "payjoinReceiveEnabled": False, **self.preferences}
        if method in ("listAnnouncements", "listMyRecipients"):
            return {"elements": []}
        if method in ("listRecipientsFiat", "listRecipients"):
            wanted = (params.get("filters") or {}).get("recipientTypeFiat")
            demo = {"recipientId": "regtest-demo-recipient", "userId": "dummy-user", "userNbr": 1,
                    "isArchived": False, "createdAt": now(), "updatedAt": now(),
                    "recipientTypeFiat": "INTERAC_EMAIL_CAD", "isOwner": True,
                    "label": "Regtest demo", "isDefault": True, "email": "demo@example.invalid",
                    "name": "Regtest Demo", "securityQuestion": "Regtest?", "securityAnswer": "regtest"}
            elements = [demo] if not wanted or "INTERAC_EMAIL_CAD" in wanted else []
            return {"elements": elements, "totalElements": len(elements)}
        if method == "listOrderSummaries":
            if self.scenario == "settle":
                for order in self.orders.values():
                    self.settle(order)
            return {"elements": list(self.orders.values())}
        if method == "saveUserPreferences":
            self.preferences.update({key: value for key, value in params.items()
                                     if key in ("currency", "language")})
            return {"success": True}
        if method == "registerResponsibilityConsent":
            return {"success": True}
        if method == "getBestSwapOption":
            amount = Decimal(str(params["amount"]))
            if not amount.is_finite() or amount <= 0:
                raise ValueError("Invalid amount")
            if params["inNetwork"] not in ("bitcoin", "liquid", "lightning") or params["outNetwork"] not in ("bitcoin", "liquid", "lightning"):
                raise ValueError("Invalid network")
            fixed_in = params.get("isInAmountFixed", True)
            incoming = amount if fixed_in else amount / Decimal("0.99")
            outgoing = amount * Decimal("0.99") if fixed_in else amount
            currency = lambda network: "LBTC" if network == "liquid" else "BTC"
            return {"inAmount": float(incoming), "outAmount": float(outgoing),
                    "inPaymentProcessorCurrencyCode": currency(params["inNetwork"]),
                    "outPaymentProcessorCurrencyCode": currency(params["outNetwork"]),
                    "orderFees": [{"percent": 1}], "warning": []}
        if self.scenario == "settle" and method in (
                "createOrderSwap", "createOrderBuy", "sellToRecipient", "sellToBalance"):
            return self.create_settled(method, params)
        if method in ("createOrderSwap", "createOrderBuy", "sellToRecipient", "sellToBalance", "createWithdrawalOrder"):
            order_id = str(uuid4())
            swap = method == "createOrderSwap"
            buy = method in ("createOrderBuy", "createWithdrawalOrder")
            amount = float(params.get("amount", params.get("bitcoinAmount", 0.001)))
            fiat = params.get("fiatCurrency", "CAD")
            payment_method = {"bitcoin": "Bitcoin On-Chain", "liquid": "Liquid Network",
                              "lightning": "Lightning Invoice (BOLT11)"}
            order = {"orderId": order_id, "orderNumber": len(self.orders) + 1,
                     "orderType": "Swap" if swap else "Buy Bitcoin" if buy else "Sell Bitcoin",
                     "payinAmount": amount if swap or not buy else params.get("fiatAmount", 100),
                     "payoutAmount": amount * 0.99 if swap else amount if buy else 99,
                     "payinCurrency": "LBTC" if params.get("inNetwork") == "liquid" else "BTC" if swap or not buy else fiat,
                     "payoutCurrency": "LBTC" if params.get("outNetwork") == "liquid" else "BTC" if swap or buy else fiat,
                     "payinMethod": payment_method.get(params.get("inNetwork", "bitcoin")) if swap or not buy else f"{fiat} Balance",
                     "payoutMethod": payment_method.get(params.get("outNetwork", params.get("network", "bitcoin"))) if swap or buy else f"{fiat} Balance",
                     "orderStatus": "Awaiting confirmation", "payinStatus": "Awaiting payment",
                     "payoutStatus": "Not started", "message": {"code": "created"},
                     "createdAt": now(), "confirmationDeadline":
                         (datetime.now(timezone.utc) + timedelta(minutes=30)).isoformat(),
                     "exchangeRateAmount": 100000, "exchangeRateCurrency": fiat}
            # Optional real regtest destinations enable the app's send screen.
            # State transitions remain simulated and never infer settlement.
            for key, env in (("bitcoinAddress", "DUMMY_BITCOIN_ADDRESS"),
                             ("liquidAddress", "DUMMY_LIQUID_ADDRESS"),
                             ("lightningInvoice", "DUMMY_LIGHTNING_INVOICE")):
                if os.environ.get(env):
                    order[key] = os.environ[env]
            self.orders[order_id] = order
            return order
        if method in ("getOrderSwapSummary", "getOrderSummary", "refreshOrderSummary", "confirmOrderSummary"):
            order = self.orders[params["orderId"]]
            if self.scenario == "settle":
                return self.settle(order, confirm=method == "confirmOrderSummary")
            if method == "confirmOrderSummary":
                order["orderStatus"] = "In progress"
            if self.scenario == "completed":
                order.update(orderStatus="Completed", payinStatus="Completed", payoutStatus="Completed",
                             completedAt=now(), sentAt=now(), message={"code": "completed"})
            elif self.scenario == "expired":
                order.update(orderStatus="Expired", message={"code": "expired"})
            return order
        raise LookupError("Method not simulated")


class Handler(BaseHTTPRequestHandler):
    exchange = Exchange()

    def log_message(self, *_):
        pass  # Never log credentials, addresses or request bodies.

    def send_json(self, status, body):
        data = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path == "/health":
            self.send_json(200, {"service": "dummy-exchange", "simulated": True,
                                 "scenario": self.exchange.scenario})
        else:
            self.send_json(404, {"error": "Not found"})

    def do_POST(self):
        request_id = None
        try:
            length = int(self.headers.get("Content-Length", "0"))
            if not 0 < length <= 65536:
                self.send_json(413, {"error": "Invalid request size"})
                return
            request = json.loads(self.rfile.read(length))
            if self.path == "/__scenario":
                scenario = request["scenario"]
                if scenario not in SCENARIOS:
                    raise ValueError("Unknown scenario")
                self.exchange.scenario = scenario
                self.send_json(200, {"scenario": scenario})
                return
            request_id = request.get("id")
            if self.exchange.scenario == "rate-limited":
                self.send_json(429, {"error": "Simulated rate limit"})
                return
            if self.exchange.scenario == "unavailable":
                self.send_json(503, {"error": "Simulated service outage"})
                return
            if os.environ.get("DUMMY_LOG_METHODS"):
                print("method", request.get("method"), self.path, flush=True)  # names only
            result = self.exchange.dispatch(request["method"], request.get("params", {}))
            self.send_json(200, {"jsonrpc": "2.0", "id": request_id, "result": result})
        except LookupError:
            self.send_json(200, {"jsonrpc": "2.0", "id": request_id,
                                 "error": {"code": -32601, "message": "Method or order not simulated"}})
        except (ValueError, TypeError, AttributeError, InvalidOperation):
            self.send_json(400, {"jsonrpc": "2.0", "id": request_id,
                                 "error": {"code": -32602, "message": "Invalid request"}})


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8088)
    args = parser.parse_args()
    server = HTTPServer((args.host, args.port), Handler)
    print(json.dumps({"host": args.host, "port": server.server_port, "simulated": True}), flush=True)
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    try:
        server.serve_forever()
    finally:
        server.server_close()
