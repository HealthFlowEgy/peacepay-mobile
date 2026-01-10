import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/presentation/widgets/gradient_button.dart';

class SetupPinScreen extends ConsumerStatefulWidget {
  const SetupPinScreen({super.key});

  @override
  ConsumerState<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends ConsumerState<SetupPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isConfirmStep = false;
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _onPinCompleted() {
    if (!_isConfirmStep) {
      setState(() {
        _isConfirmStep = true;
        _error = null;
      });
    } else {
      if (_confirmPinController.text == _pinController.text) {
        _setupPin();
      } else {
        setState(() {
          _error = 'رمز PIN غير متطابق';
          _confirmPinController.clear();
        });
      }
    }
  }

  Future<void> _setupPin() async {
    final success = await ref.read(authStateProvider.notifier).setupPin(_pinController.text);
    
    if (success && mounted) {
      context.go(Routes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    final defaultPinTheme = PinTheme(
      width: 64,
      height: 64,
      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
    );
    
    return Scaffold(
      appBar: AppBar(title: const Text('إعداد رمز PIN')),
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
                child: const Icon(Icons.lock, color: AppColors.primary, size: 40),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                _isConfirmStep ? 'تأكيد رمز PIN' : 'إنشاء رمز PIN',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirmStep
                    ? 'أعد إدخال رمز PIN للتأكيد'
                    : 'أنشئ رمز PIN من 4 أرقام لتأمين معاملاتك',
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              if (_error != null || authState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error ?? authState.error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              
              Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  controller: _isConfirmStep ? _confirmPinController : _pinController,
                  length: 4,
                  obscureText: true,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onCompleted: (_) => _onPinCompleted(),
                ),
              ),
              
              const Spacer(),
              
              if (_isConfirmStep)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isConfirmStep = false;
                      _pinController.clear();
                      _confirmPinController.clear();
                      _error = null;
                    });
                  },
                  child: const Text('إعادة إدخال رمز PIN'),
                ),
              
              const SizedBox(height: 16),
              
              GradientButton(
                onPressed: authState.isLoading ? null : _onPinCompleted,
                isLoading: authState.isLoading,
                child: Text(_isConfirmStep ? 'تأكيد' : 'التالي'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
