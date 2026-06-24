import 'package:dio/dio.dart';

class TopicExplanation {
  final String rule;
  final List<String> examples;
  final List<String> commonMistakes;
  final String tip;

  const TopicExplanation({
    required this.rule,
    required this.examples,
    required this.commonMistakes,
    required this.tip,
  });

  factory TopicExplanation.fromJson(Map<String, dynamic> json) =>
      TopicExplanation(
        rule: json['rule'] as String? ?? '',
        examples: (json['examples'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        commonMistakes: (json['commonMistakes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        tip: json['tip'] as String? ?? '',
      );
}

class TopicExplanationService {
  final Dio _dio;

  TopicExplanationService(this._dio);

  /// Rewarded reklam izlendikten SONRA çağrılır.
  /// [wrongTopics]: quiz'de yanlış yapılan soruların kısa açıklamaları (opsiyonel)
  Future<TopicExplanation> explain({
    required String level,
    required String subjectName,
    List<String> wrongTopics = const [],
  }) async {
    final response = await _dio.post('/education/explain', data: {
      'Level': level,
      'SubjectName': subjectName,
      'WrongTopics': wrongTopics,
    });
    return TopicExplanation.fromJson(response.data as Map<String, dynamic>);
  }
}
