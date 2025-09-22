import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class InactivityService with WidgetsBindingObserver {
  static final InactivityService _i = InactivityService._();
  factory InactivityService() => _i;
  InactivityService._();

  Duration timeout = const Duration(minutes: 1);
  Timer? _timer;
  bool _locked = false;

  final _lockCtrl = StreamController<void>.broadcast();
  Stream<void> get onLock => _lockCtrl.stream;

  void start() {
    if (!_started) {
      _started = true;
      WidgetsBinding.instance.addObserver(this);
      _hookGlobalInputs();
    }
    _arm();
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }

  void reset() {
    if (_locked) return;
    _arm();
  }

  void unlock() {
    _locked = false;
    _arm();
  }

  bool get isLocked => _locked;

  void _arm() {
    _timer?.cancel();
    _timer = Timer(timeout, _triggerLock);
  }

  void _triggerLock() {
    if (_locked) return;
    _locked = true;
    _lockCtrl.add(null);
  }

  // Lock when app goes background/inactive.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _triggerLock();
    }
  }

  // Global inputs reset the timer.
  void _hookGlobalInputs() {
    GestureBinding.instance.pointerRouter.addGlobalRoute((PointerEvent e) {
      if (e is PointerDownEvent || e is PointerMoveEvent || e is PointerScrollEvent) {
        reset();
      }
    });

    HardwareKeyboard.instance.addHandler((KeyEvent e) {
      reset();
      return false; // don't consume
    });
  }

  // --- internals ---
  bool _started = false;
}
