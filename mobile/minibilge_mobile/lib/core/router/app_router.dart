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
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/education/screens/subject_selection_screen.dart';
import '../../features/education/screens/topic_selection_screen.dart';
import '../../features/education/screens/english_level_select_screen.dart';
import '../../features/education/screens/level_list_screen.dart';
import '../../features/education/screens/quiz_screen.dart';
import '../../features/education/screens/quiz_result_screen.dart';
import '../../features/education/models/submit_answer_response.dart';
import '../../features/education/models/question.dart';
import '../../features/avatar/screens/avatar_profile_screen.dart';
import '../../features/collection/screens/badge_collection_screen.dart';
import '../../features/collection/screens/card_collection_screen.dart';
import '../../features/leaderboard/screens/leaderboard_screen.dart';
import '../../features/match/screens/match_request_screen.dart';
import '../../features/match/screens/match_subject_select_screen.dart';
import '../../features/match/screens/match_arena_screen.dart';
import '../../features/match/screens/match_result_screen.dart';
import '../../features/match/screens/match_history_screen.dart';
import '../../features/parent_report/screens/parent_report_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/education/screens/english_mode_select_screen.dart';
import '../../features/education/screens/podcast_list_screen.dart';
import '../../features/education/screens/podcast_player_screen.dart';
import '../../features/flashcard/screens/flashcard_deck_list_screen.dart';
import '../../features/flashcard/screens/flashcard_study_screen.dart';
import '../../features/flashcard/screens/flashcard_session_result_screen.dart';
import '../../features/flashcard/models/flashcard_models.dart';
import '../../features/education/screens/podcast_quiz_screen.dart';
import '../../features/education/screens/podcast_quiz_result_screen.dart';
import '../../features/education/models/podcast_quiz_models.dart';
import '../../features/education/screens/writing_practice_screen.dart';
import '../../features/education/screens/writing_result_screen.dart';
import '../../features/education/models/writing_models.dart';
import '../../features/education/screens/vocab_challenge_screen.dart';
import '../../features/education/screens/vocab_result_screen.dart';
import '../../features/education/models/vocab_challenge_models.dart';
import '../../features/education/screens/scenario_select_screen.dart';
import '../../features/education/screens/roleplay_screen.dart';
import '../../features/education/screens/roleplay_result_screen.dart';
import '../../features/education/models/roleplay_models.dart';
import '../../features/education/screens/pronunciation_practice_screen.dart';
import '../../features/friends/screens/friends_screen.dart';
import '../../features/challenge/screens/challenge_screen.dart';
import '../../features/classroom/screens/classrooms_screen.dart';
import '../../features/classroom/screens/classroom_detail_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);
      final childProfileState = ref.read(childProfileProvider);

      final loc = state.matchedLocation;
      final isSplash = loc == '/splash';

      // Auth henüz kontrol edilmedi — splash'te bekle
      final isInitializing = authState.maybeWhen(
        initial: () => true,
        orElse: () => false,
      );
      if (isInitializing) return isSplash ? null : '/splash';

      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );

      // Splash tamamlandı, auth state belli oldu
      if (isSplash) {
        if (!isAuthenticated) return '/login';
        return childProfileState.maybeWhen(
          loaded: (profiles) =>
              profiles.isEmpty ? '/child-profiles' : '/child-profile-selection',
          orElse: () => '/child-profiles',
        );
      }
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
      final isCollectionRoute = loc.startsWith('/badges') || loc.startsWith('/cards') || loc.startsWith('/education/podcast');
      final isFlashcardRoute = loc.startsWith('/flashcard');
      final isPodcastQuizRoute = loc.startsWith('/podcast/quiz');
      final isFriendsRoute = loc.startsWith('/friends');
      final isChallengeRoute = loc.startsWith('/challenges') || loc.startsWith('/quiz/challenge');

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
              isEducationRoute ||
              isCollectionRoute ||
              isFlashcardRoute ||
              isPodcastQuizRoute ||
              isFriendsRoute ||
              isChallengeRoute)) {
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
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const _SplashScreen(),
      ),
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
        path: '/education/english-level/:subjectId',
        name: 'education-english-level',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId']!;
          final subjectName = state.extra as String? ?? 'İngilizce';
          return EnglishLevelSelectScreen(
            subjectId: subjectId,
            subjectName: subjectName,
          );
        },
      ),
      GoRoute(
        path: '/education/english/:subjectId/level/:level/mode',
        name: 'education-english-mode',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId']!;
          final level = int.tryParse(state.pathParameters['level'] ?? '1') ?? 1;
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final subjectName = extra['subjectName'] as String? ?? 'İngilizce';
          final levelCode = extra['levelCode'] as String? ?? 'A1';
          return EnglishModeSelectScreen(
            subjectId: subjectId,
            subjectName: subjectName,
            englishLevel: level,
            levelCode: levelCode,
          );
        },
      ),
      GoRoute(
        path: '/education/podcasts/:subjectId/:level',
        name: 'podcast-list',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId']!;
          final level = int.tryParse(state.pathParameters['level'] ?? '1') ?? 1;
          final levelCode = state.extra as String? ?? 'A1';
          return PodcastListScreen(
            subjectId: subjectId,
            englishLevel: level,
            levelCode: levelCode,
          );
        },
      ),
      GoRoute(
        path: '/education/podcast/:episodeId',
        name: 'podcast-player',
        builder: (context, state) {
          final episodeId = state.pathParameters['episodeId']!;
          final title = state.extra as String?;
          return PodcastPlayerScreen(episodeId: episodeId, episodeTitle: title);
        },
      ),
      GoRoute(
        path: '/education/topics/:subjectId',
        name: 'education-topics',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId']!;
          // extra can be String (plain name) or (String, int) (name + englishLevel)
          final extra = state.extra;
          final subjectName = extra is (String, int)
              ? extra.$1
              : extra as String? ?? 'Ders';
          final englishLevel = extra is (String, int) ? extra.$2 : null;
          return TopicSelectionScreen(
            subjectId: subjectId,
            subjectName: subjectName,
            englishLevel: englishLevel,
          );
        },
      ),
      GoRoute(
        path: '/education/levels/:topicId',
        name: 'education-levels',
        builder: (context, state) {
          final topicId = state.pathParameters['topicId']!;
          final extra = state.extra;
          final String topicName;
          final String subjectName;
          if (extra is Map) {
            topicName = extra['topicName'] as String? ?? 'Konu';
            subjectName = extra['subjectName'] as String? ?? '';
          } else {
            topicName = extra as String? ?? 'Konu';
            subjectName = '';
          }
          return LevelListScreen(
            topicId: topicId,
            topicName: topicName,
            subjectName: subjectName,
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
            subjectName: extra['subjectName'] ?? '',
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
            questions: extra['questions'] as List<Question>? ?? const [],
            subjectName: extra['subjectName'] as String? ?? '',
            topicName: extra['topicName'] as String? ?? '',
            challengeId: extra['challengeId'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/avatar/profile',
        name: 'avatar-profile',
        builder: (context, state) => const AvatarProfileScreen(),
      ),
      GoRoute(
        path: '/badges',
        name: 'badge-collection',
        builder: (context, state) => const BadgeCollectionScreen(),
      ),
      GoRoute(
        path: '/cards',
        name: 'card-collection',
        builder: (context, state) => const CardCollectionScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/match/subject-select',
        name: 'match-subject-select',
        builder: (context, state) => const MatchSubjectSelectScreen(),
      ),
      GoRoute(
        path: '/match/request',
        name: 'match-request',
        builder: (context, state) {
          final subjectId = state.uri.queryParameters['subjectId'];
          final subjectName = state.uri.queryParameters['subjectName'];
          return MatchRequestScreen(subjectId: subjectId, subjectName: subjectName);
        },
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
      GoRoute(
        path: '/flashcard/decks/:level',
        name: 'flashcard-deck-list',
        builder: (context, state) {
          final level = int.tryParse(state.pathParameters['level'] ?? '1') ?? 1;
          final levelCode = state.extra as String? ?? 'A1';
          return FlashcardDeckListScreen(
            englishLevel: level,
            levelCode: levelCode,
          );
        },
      ),
      GoRoute(
        path: '/flashcard/study/:deckId',
        name: 'flashcard-study',
        builder: (context, state) {
          final deckId = state.pathParameters['deckId']!;
          final deckTitle = state.extra as String? ?? 'Kelime Destesi';
          return FlashcardStudyScreen(
            deckId: deckId,
            deckTitle: deckTitle,
          );
        },
      ),
      GoRoute(
        path: '/flashcard/result',
        name: 'flashcard-result',
        builder: (context, state) {
          final result = state.extra as FlashcardSessionResult;
          return FlashcardSessionResultScreen(result: result);
        },
      ),
      GoRoute(
        path: '/podcast/quiz/result',
        name: 'podcast-quiz-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PodcastQuizResultScreen(
            result: extra['result'] as PodcastQuizResult,
            episodeId: extra['episodeId'] as String,
          );
        },
      ),
      GoRoute(
        path: '/podcast/quiz/:episodeId',
        name: 'podcast-quiz',
        builder: (context, state) {
          final episodeId = state.pathParameters['episodeId']!;
          final title = state.extra as String? ?? 'Podcast';
          return PodcastQuizScreen(episodeId: episodeId, episodeTitle: title);
        },
      ),
      GoRoute(
        path: '/education/writing',
        name: 'writing-practice',
        builder: (context, state) {
          final level = state.uri.queryParameters['level'] ?? 'B1';
          final episodeId = state.uri.queryParameters['episodeId'];
          return WritingPracticeScreen(level: level, episodeId: episodeId);
        },
      ),
      GoRoute(
        path: '/education/writing/result',
        name: 'writing-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return WritingResultScreen(
            result: extra['result'] as WritingEvaluationResult,
            level: extra['level'] as String,
          );
        },
      ),
      GoRoute(
        path: '/education/vocab-challenge',
        name: 'vocab-challenge',
        builder: (context, state) {
          final level = state.uri.queryParameters['level'] ?? 'B1';
          return VocabChallengeScreen(level: level);
        },
      ),
      GoRoute(
        path: '/education/vocab-challenge/result',
        name: 'vocab-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return VocabResultScreen(
            result: extra['result'] as VocabChallengeResult,
            targetWords: (extra['targetWords'] as List).cast<String>(),
            level: extra['level'] as String,
          );
        },
      ),
      GoRoute(
        path: '/education/roleplay/scenarios',
        name: 'roleplay-scenarios',
        builder: (context, state) {
          final level = state.uri.queryParameters['level'] ?? 'B1';
          return ScenarioSelectScreen(level: level);
        },
      ),
      GoRoute(
        path: '/education/roleplay/session',
        name: 'roleplay-session',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return RolePlayScreen(
            scenario: extra['scenario'] as ScenarioDto,
            level: extra['level'] as String,
            childProfileId: extra['childProfileId'] as String,
          );
        },
      ),
      GoRoute(
        path: '/education/roleplay/result',
        name: 'roleplay-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return RolePlayResultScreen(
            result: extra['result'] as EndSessionResponse,
            scenario: extra['scenario'] as ScenarioDto,
          );
        },
      ),
      GoRoute(
        path: '/education/pronunciation',
        name: 'pronunciation-practice',
        builder: (context, state) {
          final levelCode = state.uri.queryParameters['level'] ?? 'A1';
          final levelInt  = int.tryParse(
                state.uri.queryParameters['levelInt'] ?? '1') ?? 1;
          return PronunciationPracticeScreen(
            level: levelCode,
            levelInt: levelInt,
          );
        },
      ),
      GoRoute(
        path: '/friends',
        name: 'friends',
        builder: (context, state) {
          final extra = state.extra;
          final initialTab = extra is Map ? (extra['tab'] as int? ?? 0) : 0;
          return FriendsScreen(initialTab: initialTab);
        },
      ),
      GoRoute(
        path: '/challenges',
        name: 'challenges',
        builder: (context, state) => const ChallengeScreen(),
      ),
      GoRoute(
        path: '/classrooms',
        name: 'classrooms',
        builder: (context, state) => const ClassroomsScreen(),
      ),
      GoRoute(
        path: '/classrooms/:id',
        name: 'classroom-detail',
        builder: (context, state) => ClassroomDetailScreen(
          classroomId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/quiz/challenge/:challengeId',
        name: 'challenge-quiz',
        builder: (context, state) {
          final challengeId = state.pathParameters['challengeId']!;
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return QuizScreen(
            key: ValueKey('challenge-quiz-$challengeId'),
            levelId: extra['levelId'] as String? ?? '',
            levelName: extra['levelName'] as String? ?? 'Seviye',
            topicName: extra['topicName'] as String? ?? 'Konu',
            subjectName: extra['subjectName'] as String? ?? '',
            challengeId: challengeId,
          );
        },
      ),
    ],
  );

  ref.listen(authProvider, (_, __) => router.refresh());

  return router;
});

/// Minimal splash screen shown while auth state is being restored.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF7EC8F0),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
