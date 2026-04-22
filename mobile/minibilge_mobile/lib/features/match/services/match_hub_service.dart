import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../models/match_models.dart';

/// SignalR hub service for real-time match communication
class MatchHubService {
  HubConnection? _hubConnection;
  final String _hubUrl;
  final FlutterSecureStorage _secureStorage;

  // Stream controllers for events
  final _matchFoundController = StreamController<MatchSession>.broadcast();
  final _opponentAnsweredController =
      StreamController<OpponentAnsweredEvent>.broadcast();
  final _opponentLeftController = StreamController<void>.broadcast();
  final _matchCompletedController = StreamController<String>.broadcast();
  final _answerSubmittedController =
      StreamController<AnswerSubmittedEvent>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _questionAdvanceController = StreamController<int>.broadcast();

  // Public streams
  Stream<MatchSession> get matchFound => _matchFoundController.stream;
  Stream<OpponentAnsweredEvent> get opponentAnswered =>
      _opponentAnsweredController.stream;
  Stream<void> get opponentLeft => _opponentLeftController.stream;
  Stream<String> get matchCompleted => _matchCompletedController.stream;
  Stream<AnswerSubmittedEvent> get answerSubmitted =>
      _answerSubmittedController.stream;
  Stream<String> get error => _errorController.stream;
  Stream<int> get questionAdvance => _questionAdvanceController.stream;

  MatchHubService({
    required String baseUrl,
    required FlutterSecureStorage secureStorage,
  })  : _hubUrl = '$baseUrl/hubs/match',
        _secureStorage = secureStorage;

  /// Connect to the match hub
  Future<void> connect() async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      return;
    }

    // Get token from secure storage
    final token = await _secureStorage.read(key: StorageKeys.accessToken) ?? '';

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
            transport: HttpTransportType.WebSockets,
          ),
        )
        .withAutomaticReconnect()
        .build();

    // Register event handlers
    _hubConnection?.on('MatchFound', _handleMatchFound);
    _hubConnection?.on('OpponentAnswered', _handleOpponentAnswered);
    _hubConnection?.on('OpponentLeft', _handleOpponentLeft);
    _hubConnection?.on('MatchCompleted', _handleMatchCompleted);
    _hubConnection?.on('AnswerSubmitted', _handleAnswerSubmitted);
    _hubConnection?.on('Error', _handleError);
    _hubConnection?.on('QuestionAdvance', _handleQuestionAdvance);

    await _hubConnection?.start();
  }

  /// Disconnect from the hub
  Future<void> disconnect() async {
    await _hubConnection?.stop();
  }

  /// Join a match session
  Future<void> joinMatch(String matchId, String childId) async {
    await _hubConnection?.invoke('JoinMatch', args: [matchId, childId]);
  }

  /// Submit an answer for the current question
  Future<void> submitAnswer(
    String matchId,
    String questionId,
    String answer,
    String childId,
  ) async {
    await _hubConnection?.invoke('SubmitAnswer', args: [
      matchId,
      questionId,
      answer,
      childId,
    ]);
  }

  /// Leave the current match
  Future<void> leaveMatch(String matchId) async {
    await _hubConnection?.invoke('LeaveMatch', args: [matchId]);
  }

  // Event handlers
  void _handleMatchFound(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final matchData = arguments[0] as Map<String, dynamic>;
      // Backend sends { matchId, status } to avoid circular reference
      final matchId = matchData['matchId'] as String;
      
      // Create a minimal MatchSession object
      final minimalMatch = MatchSession(
        id: matchId,
        status: MatchSessionStatus.created,
        startedAt: DateTime.now(),
        endedAt: null,
        winnerId: null,
        participants: [],
        questions: [],
      );
      
      _matchFoundController.add(minimalMatch);
    }
  }

  void _handleOpponentAnswered(List<Object?>? arguments) {
    if (arguments != null && arguments.length >= 2) {
      final questionNumber = (arguments[0] as num?)?.toInt() ?? 0;
      final isCorrect = arguments[1] == true;
      final newScore = arguments.length >= 3 ? (arguments[2] as num?)?.toInt() ?? 0 : 0;
      final answeredByChildId = arguments.length >= 4 ? arguments[3]?.toString() : null;
      _opponentAnsweredController.add(
        OpponentAnsweredEvent(
          questionNumber: questionNumber,
          isCorrect: isCorrect,
          newScore: newScore,
          answeredByChildId: answeredByChildId,
        ),
      );
    }
  }

  void _handleOpponentLeft(List<Object?>? arguments) {
    _opponentLeftController.add(null);
  }

  void _handleMatchCompleted(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final matchId = arguments[0] as String;
      _matchCompletedController.add(matchId);
    }
  }

  void _handleAnswerSubmitted(List<Object?>? arguments) {
    if (arguments != null && arguments.length >= 3) {
      final isCorrect = arguments[0] == true;
      final points = (arguments[1] as num?)?.toInt() ?? 0;
      final newScore = (arguments[2] as num?)?.toInt() ?? 0;
      _answerSubmittedController.add(
        AnswerSubmittedEvent(
          isCorrect: isCorrect,
          points: points,
          newScore: newScore,
        ),
      );
    }
  }

  void _handleError(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final message = arguments[0] as String;
      _errorController.add(message);
    }
  }

  void _handleQuestionAdvance(List<Object?>? arguments) {
    final questionOrder = (arguments != null && arguments.isNotEmpty)
        ? (arguments[0] as num?)?.toInt() ?? 0
        : 0;
    _questionAdvanceController.add(questionOrder);
  }

  /// Dispose resources
  void dispose() {
    _matchFoundController.close();
    _opponentAnsweredController.close();
    _opponentLeftController.close();
    _matchCompletedController.close();
    _answerSubmittedController.close();
    _errorController.close();
    _questionAdvanceController.close();
  }
}

/// Event model for opponent answered
class OpponentAnsweredEvent {
  final int questionNumber;
  final bool isCorrect;
  final int newScore;
  final String? answeredByChildId;

  OpponentAnsweredEvent({
    required this.questionNumber,
    required this.isCorrect,
    required this.newScore,
    this.answeredByChildId,
  });
}

/// Event model for answer submitted
class AnswerSubmittedEvent {
  final bool isCorrect;
  final int points;
  final int newScore;

  AnswerSubmittedEvent({
    required this.isCorrect,
    required this.points,
    required this.newScore,
  });
}

/// Match hub service provider
final matchHubServiceProvider = Provider<MatchHubService>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  
  // Get base URL without /api suffix for SignalR
  final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
  
  return MatchHubService(
    baseUrl: baseUrl,
    secureStorage: secureStorage,
  );
});
