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
import '../../features/education/screens/subject_selection_screen.dart';
import '../../features/education/screens/topic_selection_screen.dart';
import '../../features/education/screens/level_list_screen.dart';
import '../../features/education/screens/quiz_screen.dart';
import '../../features/education/screens/quiz_result_screen.dart';
import '../../features/education/models/submit_answer_response.dart';

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
      // Education routes
      GoRoute(
        path: '/education/subjects',
        name: 'education-subjects',
        builder: (context, state) => const SubjectSelectionScreen(),
      ),
      GoRoute(
        path: '/education/topics/:subjectId',
        name: 'education-topics',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId']!;
          final subjectName = state.extra as String? ?? 'Ders';
          return TopicSelectionScreen(
            subjectId: subjectId,
            subjectName: subjectName,
          );
        },
      ),
      GoRoute(
        path: '/education/levels/:topicId',
        name: 'education-levels',
        builder: (context, state) {
          final topicId = state.pathParameters['topicId']!;
          final topicName = state.extra as String? ?? 'Konu';
          return LevelListScreen(
            topicId: topicId,
            topicName: topicName,
          );
        },
      ),
      GoRoute(
        path: '/education/quiz/:levelId',
        name: 'education-quiz',
        builder: (context, state) {
          final levelId = state.pathParameters['levelId']!;
          final extra = state.extra as Map<String, String>? ?? {};
          return QuizScreen(
            levelId: levelId,
            levelName: extra['levelName'] ?? 'Seviye',
            topicName: extra['topicName'] ?? 'Konu',
          );
        },
      ),
      GoRoute(
        path: '/education/quiz-result',
        name: 'education-quiz-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QuizResultScreen(
            correctCount: extra['correctCount'] as int,
            wrongCount: extra['wrongCount'] as int,
            totalQuestions: extra['totalQuestions'] as int,
            results: extra['results'] as Map<String, SubmitAnswerResponse>,
          );
        },
      ),
    ],
  );
});
