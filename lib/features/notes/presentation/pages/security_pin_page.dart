import 'package:flutter/material.dart';
import 'package:notes_app/core/app_security_service.dart';

class SecurityPinPage extends StatefulWidget {
  const SecurityPinPage({super.key});

  @override
  State<SecurityPinPage> createState() => _SecurityPinPageState();
}

class _SecurityPinPageState extends State<SecurityPinPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  // ============================================================
  // SAVE PIN
  // ============================================================

  Future<void> _savePin() async {
    FocusScope.of(context).unfocus();

    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    // --------------------------------------------
    // VALIDATION
    // --------------------------------------------

    if (pin.length != 4) {
      setState(() {
        _errorMessage = 'PIN must be exactly 4 digits.';
      });
      return;
    }

    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      setState(() {
        _errorMessage = 'PIN must contain only numbers.';
      });
      return;
    }

    if (pin != confirmPin) {
      setState(() {
        _errorMessage = 'PINs do not match.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await AppSecurityService.instance.savePin(pin);

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Could not save PIN.';
        _isSaving = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121318),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121318),
        elevation: 0,
        title: const Text('Set PIN'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                'Create a 4-digit PIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'This PIN will be used to unlock your locked notes.',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  labelText: 'PIN',
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFF1D2027),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _confirmPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  labelText: 'Confirm PIN',
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFF1D2027),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),

                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePin,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Save PIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
