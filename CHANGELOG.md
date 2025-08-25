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
