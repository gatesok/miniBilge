import 'package:flutter_test/flutter_test.dart';
import 'package:minibilge_mobile/core/services/analytics_service.dart';

void main() {
  late FakeAnalyticsClient client;

  setUp(() {
    client = FakeAnalyticsClient();
    AnalyticsService.useClientForTesting(client, appVersion: '1.2.3');
  });

  tearDown(AnalyticsService.resetClientForTesting);

  test('adds common parameters and normalizes supported values', () async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.quizCompleted,
      parameters: {
        'correct_count': 7,
        'solved': true,
        'empty': '',
        'unsupported': Object(),
        'long_value': 'a' * 120,
      },
    );

    final event = client.events.single;
    expect(event.name, AnalyticsEvents.quizCompleted);
    expect(event.parameters['app_version'], '1.2.3');
    expect(event.parameters['platform'], isNotEmpty);
    expect(event.parameters['correct_count'], 7);
    expect(event.parameters['solved'], 1);
    expect(event.parameters.containsKey('empty'), isFalse);
    expect(event.parameters.containsKey('unsupported'), isFalse);
    expect((event.parameters['long_value'] as String).length, 100);
  });

  test('removes PII and free-form content parameters', () async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.englishActivityCompleted,
      parameters: const {
        'email': 'parent@example.com',
        'child_name': 'Test Child',
        'nickname': 'Nickname',
        'answer_text': 'Free-form student answer',
        'spoken_text': 'Recorded speech',
        'prompt': 'Private prompt',
        'activity_type': 'writing',
        'result_bucket': 'high',
      },
    );

    final parameters = client.events.single.parameters;
    expect(parameters.keys, isNot(contains('email')));
    expect(parameters.keys, isNot(contains('child_name')));
    expect(parameters.keys, isNot(contains('nickname')));
    expect(parameters.keys, isNot(contains('answer_text')));
    expect(parameters.keys, isNot(contains('spoken_text')));
    expect(parameters.keys, isNot(contains('prompt')));
    expect(parameters['activity_type'], 'writing');
    expect(parameters['result_bucket'], 'high');
  });

  test('analytics client failure never escapes into the app flow', () async {
    client.shouldThrow = true;

    await expectLater(
      AnalyticsService.logEvent(AnalyticsEvents.appOpened),
      completes,
    );
  });

  test('clearUserState clears id and grade group', () async {
    await AnalyticsService.clearUserState();

    expect(client.userIds, [null]);
    expect(client.userProperties, [('grade_group', null)]);
  });

  test('age, score and error values are bucketed without raw content', () {
    expect(AnalyticsService.gradeGroupForAge(5), 'preschool');
    expect(AnalyticsService.gradeGroupForAge(8), 'grade_3_4');
    expect(AnalyticsService.gradeGroupForAge(16), 'teen');
    expect(AnalyticsService.gradeGroupForAge(25), 'adult');
    expect(AnalyticsService.resultBucket(39), 'low');
    expect(AnalyticsService.resultBucket(40), 'medium');
    expect(AnalyticsService.resultBucket(80), 'high');
    expect(AnalyticsService.errorType(const FormatException()), 'invalid_data');
  });

  test('event guard prevents rebuild duplicates and supports reset', () async {
    final guard = AnalyticsEventGuard();

    await Future.wait([
      guard.logOnce('quiz_start', AnalyticsEvents.quizStarted),
      guard.logOnce('quiz_start', AnalyticsEvents.quizStarted),
      guard.logOnce('quiz_start', AnalyticsEvents.quizStarted),
    ]);
    expect(client.events, hasLength(1));

    guard.reset('quiz_start');
    await guard.logOnce('quiz_start', AnalyticsEvents.quizStarted);
    expect(client.events, hasLength(2));
  });
}

final class FakeAnalyticsClient implements AnalyticsClient {
  final events = <({String name, Map<String, Object> parameters})>[];
  final userIds = <String?>[];
  final userProperties = <(String, String?)>[];
  bool shouldThrow = false;

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    if (shouldThrow) throw StateError('analytics unavailable');
    events.add((name: name, parameters: parameters));
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserId(String? id) async {
    userIds.add(id);
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    userProperties.add((name, value));
  }
}
