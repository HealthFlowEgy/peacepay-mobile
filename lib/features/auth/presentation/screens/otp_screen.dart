import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/presentation/widgets/gradient_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  int _resendSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) return;
    
    final success = await ref.read(authStateProvider.notifier).verifyOtp(_otpController.text);
    
    if (success && mounted) {
      final authState = ref.read(authStateProvider);
      if (authState.requiresPin) {
        context.go(Routes.setupPin);
      } else {
        context.go(Routes.dashboard);
      }
    }
  }

  Future<void> _resendOtp() async {
    final success = await ref.read(authStateProvider.notifier).resendOtp();
    if (success) {
      setState(() => _resendSeconds = 60);
      _startResendTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال الرمز مرة أخرى')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
    
    return Scaffold(
      appBar: AppBar(title: const Text('التحقق من الهاتف')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.sms, color: AppColors.primary, size: 40),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'أدخل رمز التحقق',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'تم إرسال رمز مكون من 6 أرقام إلى\n${authState.user?.mobile ?? ''}',
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    authState.error!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  controller: _otpController,
                  focusNode: _focusNode,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onCompleted: (_) => _verifyOtp(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              if (_resendSeconds > 0)
                Text(
                  'إعادة الإرسال خلال $_resendSeconds ثانية',
                  style: const TextStyle(color: AppColors.textSecondary),
                )
              else
                TextButton(
                  onPressed: _resendOtp,
                  child: const Text('إعادة إرسال الرمز'),
                ),
              
              const Spacer(),
              
              GradientButton(
                onPressed: authState.isLoading ? null : _verifyOtp,
                isLoading: authState.isLoading,
                child: const Text('تأكيد'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
