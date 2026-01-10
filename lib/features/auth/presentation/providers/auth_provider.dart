import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../shared/domain/entities/user.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';

// Auth State
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final User? user;
  final String? token;
  final String? error;
  final bool requiresOtp;
  final bool requiresPin;
  
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.token,
    this.error,
    this.requiresOtp = false,
    this.requiresPin = false,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    User? user,
    String? token,
    String? error,
    bool? requiresOtp,
    bool? requiresPin,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error,
      requiresOtp: requiresOtp ?? this.requiresOtp,
      requiresPin: requiresPin ?? this.requiresPin,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;
  
  AuthNotifier(this._apiClient, this._storage) : super(const AuthState()) {
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        // Validate token by fetching profile
        final response = await _apiClient.get(ApiConfig.profile);
        final user = User.fromJson(response.data['data']);
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          token: token,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      await _storage.delete(key: 'auth_token');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<bool> login(String mobile, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.post(
        ApiConfig.login,
        data: {'mobile': mobile, 'password': password},
      );
      
      final data = response.data['data'];
      final token = data['token'];
      final userData = data['user'];
      
      await _storage.write(key: 'auth_token', value: token);
      
      final user = User.fromJson(userData);
      
      // Check if OTP verification needed
      final needsOtp = userData['sms_verified'] == 0;
      final needsPin = userData['has_pin'] != true;
      
      state = state.copyWith(
        isAuthenticated: !needsOtp,
        user: user,
        token: token,
        isLoading: false,
        requiresOtp: needsOtp,
        requiresPin: needsPin && !needsOtp,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'فشل تسجيل الدخول');
      return false;
    }
  }
  
  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.post(ApiConfig.verifySmsOtp, data: {'otp': otp});
      
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        requiresOtp: false,
        requiresPin: state.user?.hasPin != true,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'رمز التحقق غير صحيح');
      return false;
    }
  }
  
  Future<bool> resendOtp() async {
    try {
      await _apiClient.post(ApiConfig.resendSmsOtp);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> setupPin(String pin) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.post(ApiConfig.pinSetup, data: {'pin': pin});
      
      state = state.copyWith(
        isLoading: false,
        requiresPin: false,
        user: state.user?.copyWith(hasPin: true),
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'فشل إعداد رمز PIN');
      return false;
    }
  }
  
  Future<bool> verifyPin(String pin) async {
    try {
      await _apiClient.post(ApiConfig.pinVerify, data: {'pin': pin});
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> switchRole(UserRole role) async {
    try {
      await _apiClient.post(ApiConfig.switchRole, data: {'role': role.name});
      state = state.copyWith(user: state.user?.copyWith(currentRole: role));
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> logout() async {
    try {
      await _apiClient.get(ApiConfig.logout);
    } catch (_) {}
    
    await _storage.delete(key: 'auth_token');
    state = const AuthState();
  }
  
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  const storage = FlutterSecureStorage();
  return AuthNotifier(apiClient, storage);
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});

final currentRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(currentUserProvider)?.currentRole ?? UserRole.buyer;
});
