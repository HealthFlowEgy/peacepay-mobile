/// Login Screen with Brute Force Protection Example
/// Shows how to integrate brute force protection with login

import 'package:flutter/material.dart';
import '../services/brute_force_protection_service.dart';
import '../widgets/lockout_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _pinController = TextEditingController();
  final _bruteForce = BruteForceProtectionService();
  
  bool _isLoading = false;
  bool _isLocked = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLockout();
  }

  Future<void> _checkLockout() async {
    final locked = await _bruteForce.isLocked('login');
    setState(() => _isLocked = locked);
  }

  Future<void> _handleLogin() async {
    if (_isLocked) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Check credentials (replace with actual API)
      final success = _pinController.text == '123456';
      
      if (success) {
        await _bruteForce.recordSuccess('login');
        // Navigate to home
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        final state = await _bruteForce.recordFailure('login');
        setState(() {
          _isLocked = state.isLocked;
          _errorMessage = 'رمز PIN غير صحيح. المحاولات المتبقية: ${3 - state.failedAttempts}';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'حدث خطأ: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return LockoutScreen(
        lockoutKey: 'login',
        onUnlock: () {
          setState(() => _isLocked = false);
        },
        onResetRequest: () {
          // Navigate to PIN reset
          Navigator.pushNamed(context, '/reset-pin');
        },
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل الدخول'),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/logo.png', height: 80),
              const SizedBox(height: 48),

              // Mobile Input
              TextField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // PIN Input
              TextField(
                controller: _pinController,
                decoration: const InputDecoration(
                  labelText: 'رمز PIN',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],

              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('تسجيل الدخول'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}
