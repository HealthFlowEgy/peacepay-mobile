/// Main.dart Integration Example
/// Shows how to integrate all security features
/// 
/// Copy relevant parts to your existing main.dart

import 'package:flutter/material.dart';
import 'services/inactivity_service.dart';
import 'widgets/session_warning_dialog.dart';

// Add this to your main() function:
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeInactivityService();
  }

  void _initializeInactivityService() {
    InactivityService().initialize(
      onLogout: _handleAutoLogout,
      onWarning: _handleSessionWarning,
    );
  }

  void _handleAutoLogout() {
    // Clear auth state
    // authProvider.logout();
    
    // Navigate to login
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
      arguments: {'reason': 'inactivity'},
    );
  }

  void _handleSessionWarning() {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      SessionWarningDialog.show(
        context,
        secondsRemaining: 30,
        onExtend: () {
          InactivityService().recordActivity();
        },
        onLogout: _handleAutoLogout,
      );
    }
  }

  @override
  void dispose() {
    InactivityService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'PeacePay',
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A),
        fontFamily: 'Cairo',
      ),
      // Wrap your app with InactivityDetector
      builder: (context, child) {
        return InactivityDetector(
          child: child!,
        );
      },
      // Your routes here
      routes: {
        '/login': (context) => const Placeholder(), // Your LoginScreen
        '/home': (context) => const Placeholder(), // Your HomeScreen
      },
    );
  }
}
