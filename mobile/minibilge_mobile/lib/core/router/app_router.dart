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
import '../../features/avatar/screens/avatar_profile_screen.dart';
import '../../features/avatar/screens/avatar_shop_screen.dart';
import '../../features/avatar/screens/avatar_inventory_screen.dart';
import '../../features/leaderboard/screens/leaderboard_screen.dart';
import '../../features/match/screens/match_request_screen.dart';
import '../../features/match/screens/match_arena_screen.dart';
import '../../features/match/screens/match_result_screen.dart';
import '../../features/match/screens/match_history_screen.dart';
import '../../features/parent_report/screens/parent_report_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);
      final childProfileState = ref.read(childProfileProvider);

      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );

      final loc = state.matchedLocation;
      final isLoginRoute = loc == '/login';
      final isRegisterRoute = loc == '/register';
      final isForgotPasswordRoute = loc == '/forgot-password';
      final isResetPasswordRoute = loc == '/reset-password';
      final isChildProfileRoute = loc.startsWith('/child-profile');
      final isDashboard = loc == '/dashboard';
      final isQuizRoute = loc.startsWith('/education/quiz/');
      final isQuizResultRoute = loc == '/education/quiz-result';
      final isMatchRoute = loc.startsWith('/match');
      final isParentReportRoute = loc.startsWith('/parent-report');
      final isAvatarRoute = loc.startsWith('/avatar');
      final isLeaderboardRoute = loc.startsWith('/leaderboard');
      final isEducationRoute = loc.startsWith('/education');

      // Giriş yapılmamışsa login'e yönlendir
      if (!isAuthenticated && !isLoginRoute && !isRegisterRoute && !isForgotPasswordRoute && !isResetPasswordRoute) {
        return '/login';
      }

      // Giriş yapılmışsa bu rotalarda redirect yapma
      if (isAuthenticated &&
          (isChildProfileRoute ||
              isDashboard ||
              isQuizRoute ||
              isQuizResultRoute ||
              isMatchRoute ||
              isParentReportRoute ||
              isAvatarRoute ||
              isLeaderboardRoute ||
              isEducationRoute)) {
        return null;
      }

      // Login/register/forgot-password sayfasındayken akıllı yönlendirme
      if (isAuthenticated && (isLoginRoute || isRegisterRoute || isForgotPasswordRoute || isResetPasswordRoute)) {
        return childProfileState.maybeWhen(
          loaded: (profiles) {
            if (profiles.isEmpty) {
              return '/child-profiles';
            }
            return '/child-profile-selection';
          },
          orElse: () => '/child-profiles',
        );
      }

      return null;
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
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return ResetPasswordScreen(email: email);
        },
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
            key: ValueKey('quiz-$levelId'),
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
            levelId: extra['levelId'] as String,
            correctCount: extra['correctCount'] as int,
            wrongCount: extra['wrongCount'] as int,
            totalQuestions: extra['totalQuestions'] as int,
            results: extra['results'] as Map<String, SubmitAnswerResponse>,
          );
        },
      ),
      GoRoute(
        path: '/avatar/profile',
        name: 'avatar-profile',
        builder: (context, state) => const AvatarProfileScreen(),
      ),
      GoRoute(
        path: '/avatar/shop',
        name: 'avatar-shop',
        builder: (context, state) => const AvatarShopScreen(),
      ),
      GoRoute(
        path: '/avatar/inventory',
        name: 'avatar-inventory',
        builder: (context, state) => const AvatarInventoryScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/match/request',
        name: 'match-request',
        builder: (context, state) => const MatchRequestScreen(),
      ),
      GoRoute(
        path: '/match/arena',
        name: 'match-arena',
        builder: (context, state) {
          final matchId = state.uri.queryParameters['matchId'] ?? '';
          return MatchArenaScreen(matchId: matchId);
        },
      ),
      GoRoute(
        path: '/match/result',
        name: 'match-result',
        builder: (context, state) {
          final matchId = state.uri.queryParameters['matchId'] ?? '';
          return MatchResultScreen(matchId: matchId);
        },
      ),
      GoRoute(
        path: '/match/history',
        name: 'match-history',
        builder: (context, state) {
          final childId = state.uri.queryParameters['childId'] ?? '';
          return MatchHistoryScreen(childId: childId);
        },
      ),
      GoRoute(
        path: '/parent-report',
        name: 'parent-report',
        builder: (context, state) => const ParentReportScreen(),
      ),
    ],
  );

  ref.listen(authProvider, (_, __) => router.refresh());

  return router;
});
