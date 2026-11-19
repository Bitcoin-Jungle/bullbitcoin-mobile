# Button standardization evidence

Integrated candidate: `cfc9bb0d3b15f74c9b258668532321c8096be8b6`, compared with exact integration base `e4dd3cbb7042f2eeff3a2a8048acadd590e38a90`. This base was verified on 19 November 2026; it is not a claim about a later remote tip.

The integrated Pixel 5 corpus below is separate from the historical `972efcf8` → `5ca6b47d` / corrected `05d3a15c` corpus. Exact source revisions and APK hashes are recorded in their separate manifests. All real phone images retain original PNG bytes. Mocked fixtures are listed separately. Counts describe images and named observed states, never complete source-site, screen, state or service coverage.

## Integrated Pixel 5 comparisons

Baseline: `e4dd3cbb7042f2eeff3a2a8048acadd590e38a90` (APK SHA256 `9d0d432e9bd1adf2c365c79271878d5828a5e9a33cdea5b8cba1d2a32db0fb10`). Candidate: `cfc9bb0d3b15f74c9b258668532321c8096be8b6` (APK SHA256 `b14fe2dd5535a1982a6fc921cef208ee5f1b897a1eceae643d393a72e2ac0c1b`). All captures use the same Pixel 5 and dedicated `com.bullbitcoin.mobile.buttons.debug` app, with a fresh baseline wallet preserved across the candidate update.

The own Bitcoin regtest wallet was funded once with 200,000 sats. Receive requests and a 10,000-sat Send draft were inspected; Send stopped before Confirm; no outgoing broadcast was performed. No outgoing payment is claimed for this integrated batch. The historical S10e transfer is separate.

These 38 unretouched phone PNGs comprise nine named states × before/after × light/dark (36 images), plus two extra light inline Swap failures. All were visually reviewed; image counts do not imply exhaustive source-site or screen/state coverage.

### Light theme

| State | Before | After |
| --- | --- | --- |
| Amount preference / theme control (context only) | [View](phone-integrated/before/light/p5-amount-settings-theme-control.png) | [View](phone-integrated/after/light/p5-amount-settings-theme-control.png) |
| Receive amount: 10,000 sats | [View](phone-integrated/before/light/p5-receive-amount.png) | [View](phone-integrated/after/light/p5-receive-amount.png) |
| Receive QR / amount request | [View](phone-integrated/before/light/p5-receive-qr-amount.png) | [View](phone-integrated/after/light/p5-receive-qr-amount.png) |
| Send amount: 10,000 sats | [View](phone-integrated/before/light/p5-send-amount.png) | [View](phone-integrated/after/light/p5-send-amount.png) |
| Send confirmation draft | [View](phone-integrated/before/light/p5-send-confirm.png) | [View](phone-integrated/after/light/p5-send-confirm.png) |
| Send Advanced Options | [View](phone-integrated/before/light/p5-send-advanced.png) | [View](phone-integrated/after/light/p5-send-advanced.png) |
| Swap amount: 10,000 sats | [View](phone-integrated/before/light/p5-swap-amount.png) | [View](phone-integrated/after/light/p5-swap-amount.png) |
| Swap Max: 199,987 sats | [View](phone-integrated/before/light/p5-swap-max.png) | [View](phone-integrated/after/light/p5-swap-max.png) |
| Swap Advanced Options | [View](phone-integrated/before/light/p5-swap-advanced.png) | [View](phone-integrated/after/light/p5-swap-advanced.png) |

### Dark theme

| State | Before | After |
| --- | --- | --- |
| Amount preference / theme control (context only) | [View](phone-integrated/before/dark/p5-amount-settings-theme-control.png) | [View](phone-integrated/after/dark/p5-amount-settings-theme-control.png) |
| Receive amount: 10,000 sats | [View](phone-integrated/before/dark/p5-receive-amount.png) | [View](phone-integrated/after/dark/p5-receive-amount.png) |
| Receive QR / amount request | [View](phone-integrated/before/dark/p5-receive-qr-amount.png) | [View](phone-integrated/after/dark/p5-receive-qr-amount.png) |
| Send amount: 10,000 sats | [View](phone-integrated/before/dark/p5-send-amount.png) | [View](phone-integrated/after/dark/p5-send-amount.png) |
| Send confirmation draft | [View](phone-integrated/before/dark/p5-send-confirm.png) | [View](phone-integrated/after/dark/p5-send-confirm.png) |
| Send Advanced Options | [View](phone-integrated/before/dark/p5-send-advanced.png) | [View](phone-integrated/after/dark/p5-send-advanced.png) |
| Swap amount: 10,000 sats | [View](phone-integrated/before/dark/p5-swap-amount.png) | [View](phone-integrated/after/dark/p5-swap-amount.png) |
| Swap Max: 199,987 sats | [View](phone-integrated/before/dark/p5-swap-max.png) | [View](phone-integrated/after/dark/p5-swap-max.png) |
| Swap Advanced Options | [View](phone-integrated/before/dark/p5-swap-advanced.png) | [View](phone-integrated/after/dark/p5-swap-advanced.png) |

### Extra inline Swap failure — light only

| State | Before | After |
| --- | --- | --- |
| Generic inline error on Swap form; no review | [View](phone-integrated/before/light/p5-swap-continue-error.png) | [View](phone-integrated/after/light/p5-swap-continue-error.png) |

Swap Continue returned the same generic inline message at 10,000 sats on the baseline and 100,000 sats on the candidate. These two error frames have different inputs and are not a like-for-like amount comparison. Exact semantic tap/backend request counts were not instrumented. No Swap review/confirmation, successful quote/order or completed swap was reached; the exact failure type/backend cause is unknown. A remote swap order may have been created before the failure; these frames do not exclude that effect.

Max shows 199,987 sats from a 200,000-sat available balance. In both versions/themes, the lower Subtract fees from amount row/switch is partly hidden by the pinned footer; its full label/control state is not verified by these frames.

The thin lime frame is present in the raw candidate PNGs and retained unchanged. Its origin is undiagnosed; it is not an added comparison outline. Originals also retain status-bar times, native cursor handles/blink and scroll-position differences. The candidate Swap form has an approximately 11-pixel vertical layout offset relative to baseline; its origin was not diagnosed.

The observed role changes are red primary Continue/Confirm actions, red underlined advanced links and filled secondary Swap Max. Sheet Done remains secondary. No visible mnemonic/private key/PIN/password/token/personal message was found; public regtest addresses/QRs and test amounts remain visible. QR scan/decode, physical-display contrast and accessibility were not tested by this visual review.

## Historical real phone comparisons

| State | Before light | After light | Before dark | After dark |
| --- | --- | --- | --- | --- |
| app-settings-theme-control | [View](phone/before/light/app-settings-theme-control.png) | Not captured | Not captured | Not captured |
| dev-mode-warning | [View](phone/before/light/dev-mode-warning.png) | Not captured | Not captured | Not captured |
| onboarding-advanced | [View](phone/before/light/onboarding-advanced.png) | [View](phone/after/light/onboarding-advanced.png) | Not captured | Not captured |
| onboarding-splash | [View](phone/before/light/onboarding-splash.png) | [View](phone/after/light/onboarding-splash.png) | Not captured | Not captured |
| s10e-app-settings-theme-control | [View](phone/before/light/s10e-app-settings-theme-control.png) | [View](phone/after/light/s10e-app-settings-theme-control.png) | [View](phone/before/dark/s10e-app-settings-theme-control.png) | [View](phone/after/dark/s10e-app-settings-theme-control.png) |
| s10e-backup-reminder | Not captured | Not captured | [View](phone/before/dark/s10e-backup-reminder.png) | Not captured |
| s10e-coins-empty | [View](phone/before/light/s10e-coins-empty.png) | [View](phone/after/light/s10e-coins-empty.png) | [View](phone/before/dark/s10e-coins-empty.png) | [View](phone/after/dark/s10e-coins-empty.png) |
| s10e-coins-selected | [View](phone/before/light/s10e-coins-selected.png) | [View](phone/after/light/s10e-coins-selected.png) | [View](phone/before/dark/s10e-coins-selected.png) | [View](phone/after/dark/s10e-coins-selected.png) |
| s10e-confirmed-actions | [View](phone/before/light/s10e-confirmed-actions.png) | [View](phone/after/light/s10e-confirmed-actions.png) | [View](phone/before/dark/s10e-confirmed-actions.png) | [View](phone/after/dark/s10e-confirmed-actions.png) |
| s10e-confirmed-note-empty | [View](phone/before/light/s10e-confirmed-note-empty.png) | [View](phone/after/light/s10e-confirmed-note-empty.png) | [View](phone/before/dark/s10e-confirmed-note-empty.png) | [View](phone/after/dark/s10e-confirmed-note-empty.png) |
| s10e-confirmed-transaction | [View](phone/before/light/s10e-confirmed-transaction.png) | [View](phone/after/light/s10e-confirmed-transaction.png) | [View](phone/before/dark/s10e-confirmed-transaction.png) | [View](phone/after/dark/s10e-confirmed-transaction.png) |
| s10e-corrected-theme-control | Not captured | [View](phone/after/light/s10e-corrected-theme-control.png) | Not captured | [View](phone/after/dark/s10e-corrected-theme-control.png) |
| s10e-dev-mode-warning | Not captured | Not captured | Not captured | [View](phone/after/dark/s10e-dev-mode-warning.png) |
| s10e-funded-home | [View](phone/before/light/s10e-funded-home.png) | [View](phone/after/light/s10e-funded-home.png) | [View](phone/before/dark/s10e-funded-home.png) | [View](phone/after/dark/s10e-funded-home.png) |
| s10e-funded-theme-control | Not captured | Not captured | Not captured | [View](phone/after/dark/s10e-funded-theme-control.png) |
| s10e-history | [View](phone/before/light/s10e-history.png) | [View](phone/after/light/s10e-history.png) | [View](phone/before/dark/s10e-history.png) | [View](phone/after/dark/s10e-history.png) |
| s10e-network-restart | [View](phone/before/light/s10e-network-restart.png) | [View](phone/after/light/s10e-network-restart-fixed.png) | [View](phone/before/dark/s10e-network-restart.png) | [View](phone/after/dark/s10e-network-restart-fixed.png) |
| s10e-note-empty | Not captured | Not captured | Not captured | [View](phone/after/dark/s10e-note-empty.png) |
| s10e-onboarding-advanced | Not captured | Not captured | [View](phone/before/dark/s10e-onboarding-advanced.png) | [View](phone/after/dark/s10e-onboarding-advanced.png) |
| s10e-onboarding-splash | Not captured | Not captured | [View](phone/before/dark/s10e-onboarding-splash.png) | [View](phone/after/dark/s10e-onboarding-splash.png) |
| s10e-pin-backup-gate | [View](phone/before/light/s10e-pin-backup-gate.png) | [View](phone/after/light/s10e-pin-backup-gate.png) | [View](phone/before/dark/s10e-pin-backup-gate.png) | [View](phone/after/dark/s10e-pin-backup-gate.png) |
| s10e-quick-actions | [View](phone/before/light/s10e-quick-actions.png) | [View](phone/after/light/s10e-quick-actions.png) | [View](phone/before/dark/s10e-quick-actions.png) | [View](phone/after/dark/s10e-quick-actions.png) |
| s10e-receive-bitcoin | [View](phone/before/light/s10e-receive-bitcoin.png) | [View](phone/after/light/s10e-receive-bitcoin.png) | [View](phone/before/dark/s10e-receive-bitcoin.png) | [View](phone/after/dark/s10e-receive-bitcoin.png) |
| s10e-send-advanced | [View](phone/before/light/s10e-send-advanced.png) | [View](phone/after/light/s10e-send-advanced.png) | [View](phone/before/dark/s10e-send-advanced.png) | [View](phone/after/dark/s10e-send-advanced.png) |
| s10e-send-amount | [View](phone/before/light/s10e-send-amount.png) | [View](phone/after/light/s10e-send-amount.png) | [View](phone/before/dark/s10e-send-amount.png) | [View](phone/after/dark/s10e-send-amount.png) |
| s10e-send-confirm | [View](phone/before/light/s10e-send-confirm.png) | [View](phone/after/light/s10e-send-confirm.png) | [View](phone/before/dark/s10e-send-confirm.png) | [View](phone/after/dark/s10e-send-confirm.png) |
| s10e-send-empty | [View](phone/before/light/s10e-send-empty.png) | [View](phone/after/light/s10e-send-empty.png) | [View](phone/before/dark/s10e-send-empty.png) | [View](phone/after/dark/s10e-send-empty.png) |
| s10e-send-ready | [View](phone/before/light/s10e-send-ready.png) | [View](phone/after/light/s10e-send-ready.png) | [View](phone/before/dark/s10e-send-ready.png) | [View](phone/after/dark/s10e-send-ready.png) |
| s10e-send-success | Not captured | Not captured | Not captured | [View](phone/after/dark/s10e-send-success.png) |
| s10e-transaction-actions | Not captured | Not captured | Not captured | [View](phone/after/dark/s10e-transaction-actions.png) |
| s10e-transaction-details | Not captured | Not captured | Not captured | [View](phone/after/dark/s10e-transaction-details.png) |
| s10e-wizard-theme-control | Not captured | Not captured | [View](phone/before/dark/s10e-wizard-theme-control.png) | Not captured |
| wizard-consent-no | [View](phone/before/light/wizard-consent-no.png) | [View](phone/after/light/wizard-consent-no.png) | [View](phone/before/dark/wizard-consent-no.png) | [View](phone/after/dark/wizard-consent-no.png) |
| wizard-consent-none | [View](phone/before/light/wizard-consent-none.png) | [View](phone/after/light/wizard-consent-none.png) | [View](phone/before/dark/wizard-consent-none.png) | [View](phone/after/dark/wizard-consent-none.png) |
| wizard-journey | [View](phone/before/light/wizard-journey.png) | [View](phone/after/light/wizard-journey.png) | [View](phone/before/dark/wizard-journey.png) | [View](phone/after/dark/wizard-journey.png) |
| wizard-theme-control | [View](phone/before/light/wizard-theme-control.png) | [View](phone/after/light/wizard-theme-control.png) | [View](phone/before/dark/wizard-theme-control.png) | [View](phone/after/dark/wizard-theme-control.png) |
| wizard-welcome | [View](phone/before/light/wizard-welcome.png) | [View](phone/after/light/wizard-welcome.png) | [View](phone/before/dark/wizard-welcome.png) | [View](phone/after/dark/wizard-welcome.png) |

## Historical Bitcoin regtest operation

The dedicated wallet was funded200000sats once and broadcast one10000sat self-transfer with16sat fee. Resulting balance199984sats. Transaction hashes: funding c54006a4cae13d340f2572cc755aa456949e0f7e7206d5ead2f098183ea3ff21; self-transfer5394d4ba1d2b54abba7f1105ffb4dc2d245f89bfc58df788a64b4d2f9e815824. Self-transfer independently node-confirmed. No manual mining; no claim of Liquid/Exchange/hardware signing completion.

## Mocked production-widget fixtures

These52images are synthetic source-rendered states, not phone captures and not evidence of a live account, quote, order or funds. The existing client refuses Exchange regtest; no bypass is added. PIN interiors use masked synthetic values; actual fresh-wallet PIN creation is backup-gated.

| Fixture | Before light | After light | Before dark | After dark |
| --- | --- | --- | --- | --- |
| buy-confirm-loading | [View](fixtures/before/light/buy-confirm-loading.png) | [View](fixtures/after/light/buy-confirm-loading.png) | [View](fixtures/before/dark/buy-confirm-loading.png) | [View](fixtures/after/dark/buy-confirm-loading.png) |
| buy-confirm-quote | [View](fixtures/before/light/buy-confirm-quote.png) | [View](fixtures/after/light/buy-confirm-quote.png) | [View](fixtures/before/dark/buy-confirm-quote.png) | [View](fixtures/after/dark/buy-confirm-quote.png) |
| choose-empty | [View](fixtures/before/light/choose-empty.png) | [View](fixtures/after/light/choose-empty.png) | [View](fixtures/before/dark/choose-empty.png) | [View](fixtures/after/dark/choose-empty.png) |
| choose-ready | [View](fixtures/before/light/choose-ready.png) | [View](fixtures/after/light/choose-ready.png) | [View](fixtures/before/dark/choose-ready.png) | [View](fixtures/after/dark/choose-ready.png) |
| confirm-busy | [View](fixtures/before/light/confirm-busy.png) | [View](fixtures/after/light/confirm-busy.png) | [View](fixtures/before/dark/confirm-busy.png) | [View](fixtures/after/dark/confirm-busy.png) |
| consent-none | [View](fixtures/before/light/consent-none.png) | [View](fixtures/after/light/consent-none.png) | [View](fixtures/before/dark/consent-none.png) | [View](fixtures/after/dark/consent-none.png) |
| consent-yes | [View](fixtures/before/light/consent-yes.png) | [View](fixtures/after/light/consent-yes.png) | [View](fixtures/before/dark/consent-yes.png) | [View](fixtures/after/dark/consent-yes.png) |
| exchange-account-error | [View](fixtures/before/light/exchange-account-error.png) | [View](fixtures/after/light/exchange-account-error.png) | [View](fixtures/before/dark/exchange-account-error.png) | [View](fixtures/after/dark/exchange-account-error.png) |
| exchange-support-login | [View](fixtures/before/light/exchange-support-login.png) | [View](fixtures/after/light/exchange-support-login.png) | [View](fixtures/before/dark/exchange-support-login.png) | [View](fixtures/after/dark/exchange-support-login.png) |
| pay-payment-expired | [View](fixtures/before/light/pay-payment-expired.png) | [View](fixtures/after/light/pay-payment-expired.png) | [View](fixtures/before/dark/pay-payment-expired.png) | [View](fixtures/after/dark/pay-payment-expired.png) |
| pay-payment-preparing | [View](fixtures/before/light/pay-payment-preparing.png) | [View](fixtures/after/light/pay-payment-preparing.png) | [View](fixtures/before/dark/pay-payment-preparing.png) | [View](fixtures/after/dark/pay-payment-preparing.png) |
| sell-payment-expired | [View](fixtures/before/light/sell-payment-expired.png) | [View](fixtures/after/light/sell-payment-expired.png) | [View](fixtures/before/dark/sell-payment-expired.png) | [View](fixtures/after/dark/sell-payment-expired.png) |
| sell-payment-preparing | [View](fixtures/before/light/sell-payment-preparing.png) | [View](fixtures/after/light/sell-payment-preparing.png) | [View](fixtures/before/dark/sell-payment-preparing.png) | [View](fixtures/after/dark/sell-payment-preparing.png) |

## Limits

Dark primary links retain develop colors by explicit maintainer decision. Screenshot-pixel contrast is3.417:1 on black and5.637:1 on the actual light background; not physical-display luminance. Secret-reveal states are excluded. One wrong-route capture and the superseded clipped-label intermediate image are excluded from this gallery. Hardware/recovery-provider flows and unavailable Exchange completion states remain unexecuted.


The thin lime frame is present in the original ADB screencap PNGs and retained unchanged; its origin was not diagnosed. In the historical restart corpus specifically, it appears in both baseline and corrected captures and is not an added comparison outline. The background network row differs because changing the network triggers this mandatory dialog: the dark corrected capture follows Regtest→Mainnet and the light corrected capture restores Regtest. No mainnet funding or transaction is performed; the same funded regtest wallet is preserved.
