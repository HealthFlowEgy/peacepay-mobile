/// Lockout Screen Widget
/// Displays when user is locked out due to failed attempts
/// 
/// Part of Brute Force Protection Implementation

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/brute_force_protection_service.dart';

class LockoutScreen extends StatefulWidget {
  final String lockoutKey;
  final VoidCallback onUnlock;
  final VoidCallback? onResetRequest;

  const LockoutScreen({
    super.key,
    required this.lockoutKey,
    required this.onUnlock,
    this.onResetRequest,
  });

  @override
  State<LockoutScreen> createState() => _LockoutScreenState();
}

class _LockoutScreenState extends State<LockoutScreen> {
  final _service = BruteForceProtectionService();
  Timer? _timer;
  LockoutState _state = LockoutState();

  @override
  void initState() {
    super.initState();
    _checkState();
    _startTimer();
  }

  Future<void> _checkState() async {
    final state = await _service.getState(widget.lockoutKey);
    setState(() => _state = state);
    
    if (!state.isLocked) {
      widget.onUnlock();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkState();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPermanent = _state.level == LockoutLevel.permanent;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lock Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPermanent ? Icons.lock : Icons.lock_clock,
                    size: 64,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  isPermanent ? 'تم قفل الحساب' : 'الحساب مقفل مؤقتاً',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  isPermanent
                      ? 'تم قفل حسابك بسبب محاولات تسجيل دخول فاشلة متعددة.'
                      : 'تم قفل حسابك مؤقتاً بسبب محاولات تسجيل دخول فاشلة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                if (!isPermanent) ...[
                  // Countdown
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'يمكنك المحاولة مرة أخرى بعد:',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _state.formattedRemainingTime,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Reset Button
                  ElevatedButton(
                    onPressed: widget.onResetRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('طلب إعادة تعيين الرمز السري'),
                  ),
                ],

                const SizedBox(height: 24),

                // Failed attempts info
                Text(
                  'عدد المحاولات الفاشلة: ${_state.failedAttempts}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
