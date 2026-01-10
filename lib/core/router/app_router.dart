import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/pin_screen.dart';
import '../../features/auth/presentation/screens/registration_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/wallet/presentation/screens/add_money_screen.dart';
import '../../features/peacelink/presentation/screens/peacelinks_screen.dart';
import '../../features/peacelink/presentation/screens/peacelink_details_screen.dart';
import '../../features/peacelink/presentation/screens/create_peacelink_screen.dart';
import '../../features/dsp/presentation/screens/dsp_dashboard_screen.dart';
import '../../features/dsp/presentation/screens/dsp_deliveries_screen.dart';
import '../../features/dsp/presentation/screens/dsp_delivery_details_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/kyc_screen.dart';
import '../../features/disputes/presentation/screens/disputes_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/merchant/presentation/screens/policies_screen.dart';

class Routes {
  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const pin = '/pin';
  static const registration = '/registration';
  static const roleSelection = '/role-selection';
  static const home = '/home';
  static const wallet = '/wallet';
  static const addMoney = '/wallet/add';
  static const peacelinks = '/peacelinks';
  static const peacelinkDetails = '/peacelinks/:id';
  static const createPeacelink = '/peacelinks/create';
  static const dspDashboard = '/dsp';
  static const dspDeliveries = '/dsp/deliveries';
  static const dspDeliveryDetails = '/dsp/deliveries/:id';
  static const profile = '/profile';
  static const kyc = '/profile/kyc';
  static const disputes = '/disputes';
  static const notifications = '/notifications';
  static const policies = '/policies';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.otp,
        builder: (context, state) {
          final mobile = state.extra as String? ?? '';
          return OtpScreen(mobile: mobile);
        },
      ),
      GoRoute(
        path: Routes.pin,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return PinScreen(
            isSetup: extras['isSetup'] ?? false,
            mobile: extras['mobile'] ?? '',
          );
        },
      ),
      GoRoute(
        path: Routes.registration,
        builder: (context, state) {
          final mobile = state.extra as String? ?? '';
          return RegistrationScreen(mobile: mobile);
        },
      ),
      GoRoute(
        path: Routes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.wallet,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: Routes.addMoney,
        builder: (context, state) => const AddMoneyScreen(),
      ),
      GoRoute(
        path: Routes.peacelinks,
        builder: (context, state) => const PeaceLinksScreen(),
      ),
      GoRoute(
        path: '/peacelinks/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PeaceLinkDetailsScreen(id: id);
        },
      ),
      GoRoute(
        path: Routes.createPeacelink,
        builder: (context, state) => const CreatePeaceLinkScreen(),
      ),
      GoRoute(
        path: Routes.dspDashboard,
        builder: (context, state) => const DspDashboardScreen(),
      ),
      GoRoute(
        path: Routes.dspDeliveries,
        builder: (context, state) => const DspDeliveriesScreen(),
      ),
      GoRoute(
        path: '/dsp/deliveries/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DspDeliveryDetailsScreen(id: id);
        },
      ),
      GoRoute(
        path: Routes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: Routes.kyc,
        builder: (context, state) => const KycScreen(),
      ),
      GoRoute(
        path: Routes.disputes,
        builder: (context, state) => const DisputesScreen(),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: Routes.policies,
        builder: (context, state) => const PoliciesScreen(),
      ),
    ],
  );
});
