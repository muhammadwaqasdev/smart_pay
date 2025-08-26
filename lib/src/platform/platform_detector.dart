import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/payment_mode.dart';

/// Platform-based payment mode detection and restrictions
class PlatformDetector {
  /// Get the default payment mode for the current platform
  static PaymentMode getDefaultPaymentMode() {
    if (kIsWeb) return PaymentMode.URL;

    if (Platform.isAndroid) return PaymentMode.SDK;
    if (Platform.isIOS) return PaymentMode.SDK;
    if (Platform.isMacOS) return PaymentMode.URL;
    if (Platform.isWindows) return PaymentMode.URL;
    if (Platform.isLinux) return PaymentMode.URL;

    // Fallback for unknown platforms
    return PaymentMode.URL;
  }

  /// Check if a payment mode is supported on the current platform
  static bool isPaymentModeSupported(PaymentMode mode) {
    // SDK mode restrictions: Only available on mobile platforms
    if (mode == PaymentMode.SDK) {
      if (kIsWeb) return false;
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
        return false;
      return Platform.isAndroid || Platform.isIOS;
    }

    // URL mode is supported on all platforms
    if (mode == PaymentMode.URL) {
      return true;
    }

    return false;
  }

  /// Get the current platform name for debugging/logging
  static String getCurrentPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Platform-specific default configurations
  static Map<String, dynamic> getPlatformDefaults() {
    return {
      'platform': getCurrentPlatformName(),
      'defaultMode': getDefaultPaymentMode(),
      'supportsSdk': isPaymentModeSupported(PaymentMode.SDK),
      'supportsUrl': isPaymentModeSupported(PaymentMode.URL),
    };
  }
}
