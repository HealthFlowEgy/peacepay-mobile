import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';

class PinScreen extends ConsumerStatefulWidget {
  final bool isSetup;
  final String mobile;

  const PinScreen({
    super.key,
    this.isSetup = false,
    this.mobile = '',
  });

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isConfirming = false;
  String _firstPin = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _onPinComplete(String pin) async {
    if (widget.isSetup) {
      if (!_isConfirming) {
        setState(() {
          _firstPin = pin;
          _isConfirming = true;
        });
        _pinController.clear();
      } else {
        if (pin == _firstPin) {
          setState(() => _isLoading = true);
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            context.go(Routes.home);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('رمز PIN غير متطابق'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() {
            _isConfirming = false;
            _firstPin = '';
          });
          _pinController.clear();
        }
      }
    } else {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.go(Routes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.lock, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                widget.isSetup
                    ? (_isConfirming ? 'تأكيد رمز PIN' : 'إنشاء رمز PIN')
                    : 'أدخل رمز PIN',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isSetup
                    ? (_isConfirming ? 'أعد إدخال رمز PIN للتأكيد' : 'اختر رمز PIN سري مكون من 4 أرقام')
                    : 'أدخل رمز PIN الخاص بك للدخول',
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  controller: _pinController,
                  length: 4,
                  obscureText: true,
                  obscuringCharacter: '●',
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onCompleted: _onPinComplete,
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
              const Spacer(),
              if (!widget.isSetup)
                TextButton(
                  onPressed: () {},
                  child: const Text('نسيت رمز PIN؟'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
