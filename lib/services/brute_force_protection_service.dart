/// BruteForceProtectionService - Security Implementation
/// Tracks failed attempts and enforces lockouts
/// 
/// MISSING COMPONENT FIX - From Mobile App Audit Report

import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum LockoutLevel {
  none,
  temporary5min,
  temporary30min,
  permanent,
}

class LockoutState {
  final bool isLocked;
  final int failedAttempts;
  final DateTime? lockoutEndTime;
  final LockoutLevel level;

  LockoutState({
    this.isLocked = false,
    this.failedAttempts = 0,
    this.lockoutEndTime,
    this.level = LockoutLevel.none,
  });

  Map<String, dynamic> toJson() => {
    'isLocked': isLocked,
    'failedAttempts': failedAttempts,
    'lockoutEndTime': lockoutEndTime?.toIso8601String(),
    'level': level.index,
  };

  factory LockoutState.fromJson(Map<String, dynamic> json) {
    return LockoutState(
      isLocked: json['isLocked'] ?? false,
      failedAttempts: json['failedAttempts'] ?? 0,
      lockoutEndTime: json['lockoutEndTime'] != null 
          ? DateTime.parse(json['lockoutEndTime']) 
          : null,
      level: LockoutLevel.values[json['level'] ?? 0],
    );
  }

  int get remainingSeconds {
    if (!isLocked || lockoutEndTime == null) return 0;
    if (level == LockoutLevel.permanent) return -1;
    final remaining = lockoutEndTime!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  String get formattedRemainingTime {
    if (level == LockoutLevel.permanent) {
      return 'تم قفل الحساب. يرجى إعادة تعيين الرمز السري';
    }
    final seconds = remainingSeconds;
    if (seconds <= 0) return '';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class BruteForceProtectionService {
  static final BruteForceProtectionService _instance = 
      BruteForceProtectionService._internal();
  factory BruteForceProtectionService() => _instance;
  BruteForceProtectionService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Lockout rules
  static const Map<int, Duration> lockoutRules = {
    3: Duration(minutes: 5),    // 3 attempts = 5 min lock
    5: Duration(minutes: 30),   // 5 attempts = 30 min lock
    10: Duration.zero,          // 10 attempts = permanent lock
  };

  /// Get current lockout state for a key
  Future<LockoutState> getState(String key) async {
    try {
      final stored = await _storage.read(key: 'lockout_$key');
      if (stored == null) return LockoutState();
      
      final state = LockoutState.fromJson(jsonDecode(stored));
      
      // Check if lockout has expired
      if (state.isLocked && 
          state.level != LockoutLevel.permanent &&
          state.lockoutEndTime != null &&
          DateTime.now().isAfter(state.lockoutEndTime!)) {
        // Lockout expired, reset
        await _storage.delete(key: 'lockout_$key');
        return LockoutState();
      }
      
      return state;
    } catch (e) {
      return LockoutState();
    }
  }

  /// Record a failed attempt
  Future<LockoutState> recordFailure(String key) async {
    final currentState = await getState(key);
    final newAttempts = currentState.failedAttempts + 1;
    
    // Determine lockout duration
    Duration? lockoutDuration;
    LockoutLevel level = LockoutLevel.none;
    
    for (final entry in lockoutRules.entries) {
      if (newAttempts >= entry.key) {
        lockoutDuration = entry.value;
        if (entry.key == 3) level = LockoutLevel.temporary5min;
        else if (entry.key == 5) level = LockoutLevel.temporary30min;
        else if (entry.key == 10) level = LockoutLevel.permanent;
      }
    }

    DateTime? lockoutEndTime;
    bool isLocked = false;
    
    if (lockoutDuration != null) {
      isLocked = true;
      if (lockoutDuration != Duration.zero) {
        lockoutEndTime = DateTime.now().add(lockoutDuration);
      }
    }

    final newState = LockoutState(
      isLocked: isLocked,
      failedAttempts: newAttempts,
      lockoutEndTime: lockoutEndTime,
      level: level,
    );

    await _storage.write(
      key: 'lockout_$key',
      value: jsonEncode(newState.toJson()),
    );

    return newState;
  }

  /// Record a successful attempt (clears lockout)
  Future<void> recordSuccess(String key) async {
    await _storage.delete(key: 'lockout_$key');
  }

  /// Check if currently locked
  Future<bool> isLocked(String key) async {
    final state = await getState(key);
    return state.isLocked;
  }

  /// Force reset lockout (admin action)
  Future<void> forceReset(String key) async {
    await _storage.delete(key: 'lockout_$key');
  }

  /// Stream of lockout state updates
  Stream<LockoutState> watchState(String key) async* {
    while (true) {
      yield await getState(key);
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
