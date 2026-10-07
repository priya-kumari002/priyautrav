import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/footer_illustration.dart';
import '../widgets/shifter_logo.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone, this.devOtpHint});

  final String phone;
  final String? devOtpHint;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    if (_otpCtrl.text.length != 4) {
      setState(() => _error = 'Enter 4-digit OTP');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiService.instance.verifyOtp(widget.phone, _otpCtrl.text);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final masked = '+91 ${widget.phone}';
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const ShifterLogo(size: 32),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 1),
                    Text(
                      'Verify Phone\nNumber',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter the 4 digit code sent to $masked',
                      style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                    ),
                    if (widget.devOtpHint != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Dev OTP: ${widget.devOtpHint}',
                        style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 28),
                    PinCodeTextField(
                      appContext: context,
                      length: 4,
                      controller: _otpCtrl,
                      keyboardType: TextInputType.number,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12),
                        fieldHeight: 56,
                        fieldWidth: 56,
                        activeFillColor: AppColors.surface,
                        inactiveFillColor: AppColors.surface,
                        selectedFillColor: AppColors.surface,
                        activeColor: AppColors.primary,
                        selectedColor: AppColors.primary,
                        inactiveColor: AppColors.divider,
                      ),
                      enableActiveFill: true,
                      onChanged: (_) => setState(() => _error = null),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.dropRed)),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _verify,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Verify OTP'),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
            const FooterIllustration(variant: 1),
          ],
        ),
      ),
    );
  }
}
