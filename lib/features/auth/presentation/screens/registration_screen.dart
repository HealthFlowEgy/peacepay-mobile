import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/presentation/widgets/gradient_button.dart';
import '../../../../shared/presentation/widgets/custom_text_field.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final String mobile;

  const RegistrationScreen({super.key, required this.mobile});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب الموافقة على الشروط والأحكام')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      context.go(Routes.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('أهلاً بك في PeacePay!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('أكمل بياناتك للمتابعة', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسمك',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'الاسم مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني (اختياري)',
                  hint: 'example@email.com',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                        child: const Text.rich(
                          TextSpan(
                            text: 'أوافق على ',
                            children: [
                              TextSpan(
                                text: 'الشروط والأحكام',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                              TextSpan(text: ' و'),
                              TextSpan(
                                text: ' سياسة الخصوصية',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                GradientButton(
                  onPressed: _isLoading ? null : _register,
                  isLoading: _isLoading,
                  child: const Text('متابعة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
