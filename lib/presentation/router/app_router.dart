import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/auth_providers.dart';
import 'go_router_refresh_stream.dart';
import '../../data/firebase/auth_service.dart';
import '../screens/app_shell.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/blog/blog_screen.dart';
import '../screens/plans/plans_screen.dart';
import '../screens/plans/plan_comparison_screen.dart';
import '../screens/plans/plan_detail_screen.dart';
import '../screens/bookings/bookings_screen.dart';
import '../screens/bookings/booking_success_screen.dart';
import '../screens/profile/account_entry_screen.dart';
import '../screens/profile/dependents_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/debug_explorer_screen.dart';
import '../screens/profile/help_screen.dart';
import '../screens/profile/privacy_policy_screen.dart';
import '../screens/splash/splash_sequence.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/manage_content_screen.dart';
import '../screens/admin/manage_hotels_screen.dart';
import '../screens/admin/manage_activities_screen.dart';
import '../screens/admin/manage_events_screen.dart';
import '../screens/admin/admin_settings_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
const String _kHasSeenSplash = 'has_seen_splash_v1';

final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final authService = AuthService();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(auth.idTokenChanges()),
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenSplash = prefs.getBool(_kHasSeenSplash) ?? false;

      if (!hasSeenSplash && state.matchedLocation != '/splash') {
        return '/splash';
      }
      if (hasSeenSplash && state.matchedLocation == '/splash') {
        return '/home';
      }

      final matchedLocation = state.matchedLocation;
      final user = auth.currentUser;
      final loggedIn = user != null;
      final isAdminRoute =
          matchedLocation == '/admin' || matchedLocation.startsWith('/admin/');
      final isRegisterRoute = matchedLocation == '/account/register';
      final isProtectedAccountRoute =
          matchedLocation.startsWith('/account/') &&
          matchedLocation != '/account/register' &&
          matchedLocation != '/account/login';
      final isUserOnlyRoute =
          matchedLocation == '/home' ||
          matchedLocation == '/blog' ||
          matchedLocation == '/plans' ||
          matchedLocation.startsWith('/plans/') ||
          matchedLocation == '/account' ||
          matchedLocation.startsWith('/account/') ||
          matchedLocation == '/profile' ||
          matchedLocation.startsWith('/profile/') ||
          matchedLocation == '/bookings' ||
          matchedLocation == '/booking-success' ||
          matchedLocation == '/dependents' ||
          matchedLocation == '/settings' ||
          matchedLocation == '/edit-profile';

      bool? cachedAdmin;
      Future<bool> resolveIsAdmin() async {
        if (cachedAdmin != null) return cachedAdmin!;
        cachedAdmin = await authService.isAdmin(user: user);
        return cachedAdmin!;
      }

      if (matchedLocation == '/account/login') {
        return '/account';
      }

      if (loggedIn && isRegisterRoute) {
        final isAdmin = await resolveIsAdmin();
        return isAdmin ? '/admin' : '/account';
      }

      if (!loggedIn && isProtectedAccountRoute) {
        return '/account';
      }
      if (!loggedIn && isAdminRoute) {
        return '/account';
      }
      if (loggedIn && isAdminRoute) {
        final isAdmin = await resolveIsAdmin();
        if (!isAdmin) {
          return '/account';
        }
      }

      if (loggedIn && isUserOnlyRoute) {
        final isAdmin = await resolveIsAdmin();
        if (isAdmin) {
          return '/admin';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashSequence(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/blog',
                builder: (context, state) => const BlogScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plans',
                builder: (context, state) => const PlansScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final data = state.extra;
                      if (data is! PlanDetailData) {
                        return const _MissingRoutePayloadScreen(
                          title: 'Plan details',
                          message: 'Plan details are unavailable.',
                        );
                      }
                      return PlanDetailScreen(data: data);
                    },
                  ),
                  GoRoute(
                    path: 'compare',
                    builder: (context, state) {
                      final payload = state.extra is PlanComparisonPayload
                          ? state.extra as PlanComparisonPayload
                          : null;
                      return PlanComparisonScreen(payload: payload);
                    },
                  ),
                  GoRoute(
                    path: 'booking-success',
                    builder: (context, state) {
                      final type = state.uri.queryParameters['type'] ?? '';
                      return BookingSuccessScreen(itemType: type);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountEntryScreen(),
                routes: [
                  GoRoute(
                    path: 'register',
                    builder: (context, state) => const RegisterScreen(),
                  ),
                  GoRoute(
                    path: 'edit-profile',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'dependents',
                    builder: (context, state) => const DependentsScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'help',
                    builder: (context, state) => const HelpScreen(),
                  ),
                  GoRoute(
                    path: 'privacy-policy',
                    builder: (context, state) => const PrivacyPolicyScreen(),
                  ),
                  GoRoute(
                    path: 'bookings',
                    builder: (context, state) => const BookingsScreen(),
                  ),
                  GoRoute(
                    path: 'debug-explorer',
                    builder: (context, state) => const DebugExplorerScreen(),
                  ),
                  GoRoute(
                    path: 'login',
                    redirect: (context, state) => '/account',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/profile/debug-explorer',
        redirect: (context, state) => '/account/debug-explorer',
      ),
      GoRoute(path: '/profile', redirect: (context, state) => '/account'),
      GoRoute(
        path: '/dependents',
        redirect: (context, state) => '/account/dependents',
      ),
      GoRoute(
        path: '/settings',
        redirect: (context, state) => '/account/settings',
      ),
      GoRoute(path: '/help', builder: (context, state) => const HelpScreen()),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        redirect: (context, state) => '/account/edit-profile',
      ),
      GoRoute(
        path: '/bookings',
        redirect: (context, state) => '/account/bookings',
      ),
      GoRoute(
        path: '/booking-success',
        redirect: (context, state) {
          final query = state.uri.query;
          return query.isEmpty
              ? '/plans/booking-success'
              : '/plans/booking-success?$query';
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'manage-content',
            builder: (context, state) => const ManageContentScreen(),
          ),
          GoRoute(
            path: 'hotels',
            builder: (context, state) => const ManageHotelsScreen(),
          ),
          GoRoute(
            path: 'activities',
            builder: (context, state) => const ManageActivitiesScreen(),
          ),
          GoRoute(
            path: 'events',
            builder: (context, state) => const ManageEventsScreen(),
          ),
          GoRoute(
            path: 'bookings',
            builder: (context, state) =>
                const BookingsScreen(showAllForAdmin: true),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

class _MissingRoutePayloadScreen extends StatelessWidget {
  final String title;
  final String message;

  const _MissingRoutePayloadScreen({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(message)),
    );
  }
}
