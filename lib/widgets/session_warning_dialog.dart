/// Session Warning Dialog
/// Shows countdown before auto-logout
/// 
/// Part of Auto-Logout Implementation

import 'dart:async';
import 'package:flutter/material.dart';

class SessionWarningDialog extends StatefulWidget {
  final int secondsRemaining;
  final VoidCallback onExtend;
  final VoidCallback onLogout;

  const SessionWarningDialog({
    super.key,
    required this.secondsRemaining,
    required this.onExtend,
    required this.onLogout,
  });

  static Future<void> show(
    BuildContext context, {
    required int secondsRemaining,
    required VoidCallback onExtend,
    required VoidCallback onLogout,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionWarningDialog(
        secondsRemaining: secondsRemaining,
        onExtend: onExtend,
        onLogout: onLogout,
      ),
    );
  }

  @override
  State<SessionWarningDialog> createState() => _SessionWarningDialogState();
}

class _SessionWarningDialogState extends State<SessionWarningDialog> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.secondsRemaining;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          timer.cancel();
          Navigator.of(context).pop();
          widget.onLogout();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.timer, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('تحذير انتهاء الجلسة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'سيتم تسجيل خروجك تلقائياً بسبب عدم النشاط.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Countdown Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: _remaining / widget.secondsRemaining,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _remaining <= 10 ? Colors.red : Colors.orange,
                    ),
                  ),
                ),
                Text(
                  '$_remaining',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _remaining <= 10 ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'ثانية متبقية',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onLogout();
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onExtend();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
            child: const Text('متابعة الجلسة'),
          ),
        ],
      ),
    );
  }
}
