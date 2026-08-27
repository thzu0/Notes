import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AppSecurityService {
  AppSecurityService._();

  static final AppSecurityService instance = AppSecurityService._();

  static const String _pinKey = 'app_security_pin';
  static const String _biometricKey = 'app_security_biometric_enabled';
  final LocalAuthentication _localAuth = LocalAuthentication();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ============================================================
  // BIOMETRIC SUPPORT
  // ============================================================

  Future<bool> canUseBiometrics() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();

      if (!isSupported) {
        return false;
      }

      final available = await _localAuth.getAvailableBiometrics();

      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final canUse = await canUseBiometrics();

      if (!canUse) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock your note',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // PIN
  // ============================================================

  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  Future<String?> getPin() async {
    return _storage.read(key: _pinKey);
  }

  Future<bool> hasPin() async {
    final pin = await getPin();
    return pin != null && pin.isNotEmpty;
  }

  Future<bool> verifyPin(String pin) async {
    final savedPin = await getPin();

    if (savedPin == null || savedPin.isEmpty) {
      return false;
    }

    return savedPin == pin;
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _pinKey);
  }

  // ============================================================
  // BIOMETRIC
  // ============================================================

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricKey, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricKey);

    return value == 'true';
  }
  // ============================================================
  // BIOMETRIC PROMPT
  // ============================================================

  static const String _biometricPromptKey =
      'app_security_biometric_prompt_shown';

  Future<bool> hasAskedBiometricPrompt() async {
    final value = await _storage.read(key: _biometricPromptKey);

    return value == 'true';
  }

  Future<void> setBiometricPromptShown() async {
    await _storage.write(key: _biometricPromptKey, value: 'true');
  }
}
