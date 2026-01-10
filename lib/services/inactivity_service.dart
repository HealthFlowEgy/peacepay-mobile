/// InactivityService - Auto Logout Implementation
/// Automatically logs out user after 3 minutes of inactivity
/// 
/// MISSING COMPONENT FIX - From Mobile App Audit Report

import 'dart:async';
import 'package:flutter/material.dart';

class InactivityService extends WidgetsBindingObserver {
  static final InactivityService _instance = InactivityService._internal();
  factory InactivityService() => _instance;
  InactivityService._internal();

  // Configuration
  static const int inactivityTimeoutSeconds = 180; // 3 minutes
  static const int warningBeforeSeconds = 30; // 30 seconds warning

  Timer? _inactivityTimer;
  Timer? _warningTimer;
  DateTime? _lastActivityTime;
  
  VoidCallback? _onLogout;
  VoidCallback? _onWarning;
  bool _isInitialized = false;
  bool _isPaused = false;

  /// Initialize the inactivity service
  void initialize({
    required VoidCallback onLogout,
    VoidCallback? onWarning,
  }) {
    if (_isInitialized) return;
    
    _onLogout = onLogout;
    _onWarning = onWarning;
    _isInitialized = true;
    _lastActivityTime = DateTime.now();
    
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  /// Dispose the service
  void dispose() {
    _inactivityTimer?.cancel();
    _warningTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
  }

  /// Record user activity - call this on any user interaction
  void recordActivity() {
    if (!_isInitialized || _isPaused) return;
    
    _lastActivityTime = DateTime.now();
    _resetTimers();
  }

  /// Pause the inactivity timer
  void pause() {
    _isPaused = true;
    _inactivityTimer?.cancel();
    _warningTimer?.cancel();
  }

  /// Resume the inactivity timer
  void resume() {
    _isPaused = false;
    _lastActivityTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _inactivityTimer?.cancel();
    _warningTimer?.cancel();

    // Warning timer
    _warningTimer = Timer(
      Duration(seconds: inactivityTimeoutSeconds - warningBeforeSeconds),
      () => _onWarning?.call(),
    );

    // Logout timer
    _inactivityTimer = Timer(
      Duration(seconds: inactivityTimeoutSeconds),
      () => _onLogout?.call(),
    );
  }

  void _resetTimers() {
    _startTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        pause();
        break;
      case AppLifecycleState.resumed:
        if (_lastActivityTime != null) {
          final elapsed = DateTime.now().difference(_lastActivityTime!).inSeconds;
          if (elapsed >= inactivityTimeoutSeconds) {
            _onLogout?.call();
          } else {
            resume();
          }
        }
        break;
    }
  }

  int get remainingSeconds {
    if (_lastActivityTime == null) return inactivityTimeoutSeconds;
    final elapsed = DateTime.now().difference(_lastActivityTime!).inSeconds;
    return (inactivityTimeoutSeconds - elapsed).clamp(0, inactivityTimeoutSeconds);
  }
}

/// Wrapper widget that detects user activity
class InactivityDetector extends StatelessWidget {
  final Widget child;

  const InactivityDetector({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => InactivityService().recordActivity(),
      onPanDown: (_) => InactivityService().recordActivity(),
      onScaleStart: (_) => InactivityService().recordActivity(),
      child: Listener(
        onPointerDown: (_) => InactivityService().recordActivity(),
        onPointerMove: (_) => InactivityService().recordActivity(),
        child: child,
      ),
    );
  }
}
