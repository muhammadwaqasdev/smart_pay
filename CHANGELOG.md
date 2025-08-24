## 0.0.1

- Initial release: core API `SmartPay.configure`, `SmartPayMethods` widget, and `SmartPay.checkout`.
- Provider contract: `PaymentProviderPlugin`.
- Stripe PaymentSheet support with two flows:
  - Backend-provided client secret (recommended)
  - In-package REST (dev/sandbox)
- Dynamic flow selection via `PaymentFlowMode { auto, backend, inPackage }`.
- Models: `PayRequest`, `PaymentResult`.
- Example app, README, MIT LICENSE, CONTRIBUTING.
