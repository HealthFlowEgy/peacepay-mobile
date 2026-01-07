// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/phone_entry_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/pin_setup_screen.dart';
import '../../features/auth/presentation/screens/pin_entry_screen.dart';
import '../../features/home/presentation/screens/buyer_home_screen.dart';
import '../../features/home/presentation/screens/merchant_home_screen.dart';
import '../../features/home/presentation/screens/dsp_home_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/wallet/presentation/screens/transaction_history_screen.dart';
import '../../features/wallet/presentation/screens/cashout_screen.dart';
import '../../features/peacelink/presentation/screens/buyer/peacelink_approval_screen.dart';
import '../../features/peacelink/presentation/screens/buyer/peacelink_detail_buyer_screen.dart';
import '../../features/peacelink/presentation/screens/merchant/create_peacelink_screen.dart';
import '../../features/peacelink/presentation/screens/merchant/peacelink_detail_merchant_screen.dart';
import '../../features/peacelink/presentation/screens/merchant/peacelink_list_screen.dart';
import '../../features/peacelink/presentation/screens/merchant/assign_dsp_screen.dart';
import '../../features/peacelink/presentation/screens/dsp/delivery_list_screen.dart';
import '../../features/peacelink/presentation/screens/dsp/delivery_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authState,
    
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final hasPin = authState.hasPin;
      final currentPath = state.matchedLocation;
      
      // Auth flow paths
      final isAuthPath = currentPath.startsWith('/auth');
      final isSplash = currentPath == Routes.splash;
      
      // If on splash, let it handle navigation
      if (isSplash) return null;
      
      // Not logged in - redirect to login
      if (!isLoggedIn && !isAuthPath) {
        return Routes.phoneEntry;
      }
      
      // Logged in but no PIN - redirect to PIN setup
      if (isLoggedIn && !hasPin && currentPath != Routes.pinSetup) {
        return Routes.pinSetup;
      }
      
      // Logged in with PIN but on auth path - redirect to home
      if (isLoggedIn && hasPin && isAuthPath) {
        return _getHomeRoute(authState.userRole);
      }
      
      return null;
    },
    
    routes: [
      // Splash
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: Routes.phoneEntry,
        name: 'phoneEntry',
        builder: (context, state) => const PhoneEntryScreen(),
      ),
      GoRoute(
        path: Routes.otpVerification,
        name: 'otpVerification',
        builder: (context, state) {
          final phone = state.extra as String?;
          return OtpVerificationScreen(phone: phone ?? '');
        },
      ),
      GoRoute(
        path: Routes.pinSetup,
        name: 'pinSetup',
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: Routes.pinEntry,
        name: 'pinEntry',
        builder: (context, state) => const PinEntryScreen(),
      ),
      
      // Buyer Routes
      ShellRoute(
        builder: (context, state, child) => BuyerShell(child: child),
        routes: [
          GoRoute(
            path: Routes.buyerHome,
            name: 'buyerHome',
            builder: (context, state) => const BuyerHomeScreen(),
          ),
          GoRoute(
            path: Routes.buyerWallet,
            name: 'buyerWallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: Routes.buyerProfile,
            name: 'buyerProfile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // Merchant Routes
      ShellRoute(
        builder: (context, state, child) => MerchantShell(child: child),
        routes: [
          GoRoute(
            path: Routes.merchantHome,
            name: 'merchantHome',
            builder: (context, state) => const MerchantHomeScreen(),
          ),
          GoRoute(
            path: Routes.merchantOrders,
            name: 'merchantOrders',
            builder: (context, state) => const PeacelinkListScreen(),
          ),
          GoRoute(
            path: Routes.merchantWallet,
            name: 'merchantWallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: Routes.merchantProfile,
            name: 'merchantProfile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // DSP Routes
      ShellRoute(
        builder: (context, state, child) => DspShell(child: child),
        routes: [
          GoRoute(
            path: Routes.dspHome,
            name: 'dspHome',
            builder: (context, state) => const DspHomeScreen(),
          ),
          GoRoute(
            path: Routes.dspDeliveries,
            name: 'dspDeliveries',
            builder: (context, state) => const DeliveryListScreen(),
          ),
          GoRoute(
            path: Routes.dspWallet,
            name: 'dspWallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: Routes.dspProfile,
            name: 'dspProfile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // Shared Routes (accessible from any role)
      GoRoute(
        path: Routes.peacelinkApproval,
        name: 'peacelinkApproval',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PeacelinkApprovalScreen(peacelinkId: id);
        },
      ),
      GoRoute(
        path: Routes.peacelinkDetailBuyer,
        name: 'peacelinkDetailBuyer',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PeacelinkDetailBuyerScreen(peacelinkId: id);
        },
      ),
      GoRoute(
        path: Routes.peacelinkDetailMerchant,
        name: 'peacelinkDetailMerchant',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PeacelinkDetailMerchantScreen(peacelinkId: id);
        },
      ),
      GoRoute(
        path: Routes.createPeacelink,
        name: 'createPeacelink',
        builder: (context, state) => const CreatePeacelinkScreen(),
      ),
      GoRoute(
        path: Routes.assignDsp,
        name: 'assignDsp',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AssignDspScreen(peacelinkId: id);
        },
      ),
      GoRoute(
        path: Routes.deliveryDetail,
        name: 'deliveryDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DeliveryDetailScreen(peacelinkId: id);
        },
      ),
      GoRoute(
        path: Routes.transactionHistory,
        name: 'transactionHistory',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: Routes.cashout,
        name: 'cashout',
        builder: (context, state) => const CashoutScreen(),
      ),
      GoRoute(
        path: Routes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});

String _getHomeRoute(String? role) {
  switch (role) {
    case 'merchant':
      return Routes.merchantHome;
    case 'dsp':
    case 'dsp_driver':
      return Routes.dspHome;
    case 'buyer':
    default:
      return Routes.buyerHome;
  }
}

// Shell widgets for bottom navigation
class BuyerShell extends StatelessWidget {
  final Widget child;
  const BuyerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const BuyerBottomNav(),
    );
  }
}

class MerchantShell extends StatelessWidget {
  final Widget child;
  const MerchantShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const MerchantBottomNav(),
    );
  }
}

class DspShell extends StatelessWidget {
  final Widget child;
  const DspShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const DspBottomNav(),
    );
  }
}

// Bottom Navigation Widgets (implement separately)
class BuyerBottomNav extends StatelessWidget {
  const BuyerBottomNav({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MerchantBottomNav extends StatelessWidget {
  const MerchantBottomNav({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class DspBottomNav extends StatelessWidget {
  const DspBottomNav({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

// lib/core/router/routes.dart
class Routes {
  Routes._();
  
  // Auth
  static const String splash = '/';
  static const String phoneEntry = '/auth/phone';
  static const String otpVerification = '/auth/otp';
  static const String pinSetup = '/auth/pin-setup';
  static const String pinEntry = '/auth/pin';
  
  // Buyer
  static const String buyerHome = '/buyer';
  static const String buyerWallet = '/buyer/wallet';
  static const String buyerProfile = '/buyer/profile';
  
  // Merchant
  static const String merchantHome = '/merchant';
  static const String merchantOrders = '/merchant/orders';
  static const String merchantWallet = '/merchant/wallet';
  static const String merchantProfile = '/merchant/profile';
  static const String createPeacelink = '/merchant/create';
  
  // DSP
  static const String dspHome = '/dsp';
  static const String dspDeliveries = '/dsp/deliveries';
  static const String dspWallet = '/dsp/wallet';
  static const String dspProfile = '/dsp/profile';
  
  // PeaceLink
  static const String peacelinkApproval = '/peacelink/:id/approve';
  static const String peacelinkDetailBuyer = '/peacelink/:id/buyer';
  static const String peacelinkDetailMerchant = '/peacelink/:id/merchant';
  static const String assignDsp = '/peacelink/:id/assign-dsp';
  static const String deliveryDetail = '/delivery/:id';
  
  // Common
  static const String transactionHistory = '/transactions';
  static const String cashout = '/cashout';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
}
