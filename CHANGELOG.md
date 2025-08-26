## 0.1.1

- Unified `StripeProvider()` constructor (removed named constructors)
- Added automatic platform detection (SDK on mobile, URL on web/desktop)
- Introduced `displayName` for customizable method names
- Simplified docs: split into guides, added methods table, FAQ & troubleshooting
- Example app updated for better UX
- Backward compatible, all tests passing

---

## 0.1.0

- **StripeProvider enhancements**
  - Added support for Payment Link.
- Improved integration flexibility with Stripe.
- Minor internal improvements and code cleanup.

---

## 0.0.1

- Initial release: core API `SmartPay.configure`, `SmartPayMethods` widget, and `SmartPay.checkout`.
- Provider contract: `PaymentProviderPlugin`.
- Stripe PaymentSheet support with two flows:
  - Backend-provided client secret (recommended)
  - In-package REST (dev/sandbox)
- Dynamic flow selection via `PaymentFlowMode { auto, backend, inPackage }`.
- Models: `PayRequest`, `PaymentResult`.
- Example app, README, MIT LICENSE, CONTRIBUTING.
