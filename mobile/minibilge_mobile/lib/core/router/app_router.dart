import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/child_profile/screens/child_profile_list_screen.dart';
import '../../features/child_profile/screens/child_profile_form_screen.dart';
import '../../features/child_profile/screens/child_profile_selection_screen.dart';
import '../../features/child_profile/providers/child_profile_provider.dart';
import '../../features/child_profile/providers/selected_child_provider.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final childProfileState = ref.watch(childProfileProvider);
  final selectedChild = ref.watch(selectedChildProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );

      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';
      final isProfileManagement = state.matchedLocation.startsWith('/child-profile');

      // Kullanıcı giriş yapmamışsa ve login/register sayfasında değilse -> login'e yönlendir
      if (!isAuthenticated && !isLoginRoute && !isRegisterRoute) {
        return '/login';
      }

      // Kullanıcı giriş yapmışsa ve login/register sayfasındaysa -> smart routing
      if (isAuthenticated && (isLoginRoute || isRegisterRoute)) {
        // Load profiles first
        return childProfileState.maybeWhen(
          loaded: (profiles) {
            if (profiles.isEmpty) {
              // No profiles -> go to profile management
              return '/child-profiles';
            } else if (profiles.length == 1) {
              // Single child -> auto-select and go to dashboard
              // This will be handled by selectedChildProvider
              return '/child-profile-selection';
            } else {
              // Multiple children -> go to selection screen
              return '/child-profile-selection';
            }
          },
          orElse: () => '/child-profiles',
        );
      }

      return null; // No redirect
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/child-profiles',
        name: 'child-profiles',
        builder: (context, state) => const ChildProfileListScreen(),
      ),
      GoRoute(
        path: '/child-profile/add',
        name: 'child-profile-add',
        builder: (context, state) => const ChildProfileFormScreen(),
      ),
      GoRoute(
        path: '/child-profile/edit/:id',
        name: 'child-profile-edit',
        builder: (context, state) {
          final profileId = state.pathParameters['id'];
          return ChildProfileFormScreen(profileId: profileId);
        },
      ),
      GoRoute(
        path: '/child-profile-selection',
        name: 'child-profile-selection',
        builder: (context, state) => const ChildProfileSelectionScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});
