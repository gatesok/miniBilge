import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minibilge_mobile/features/education/models/question.dart';
import 'package:minibilge_mobile/features/education/models/question_option.dart';
import 'package:minibilge_mobile/features/education/widgets/answer_widget.dart';

void main() {
  testWidgets('renders four choices even when displayOrder is one-based', (
    tester,
  ) async {
    final question = Question(
      id: 'q1',
      levelId: '',
      questionText: 'Test sorusu',
      questionType: QuestionType.multipleChoice,
      options: List.generate(
        4,
        (index) => QuestionOption(
          id: String.fromCharCode(65 + index),
          optionText: 'Seçenek ${index + 1}',
          displayOrder: index + 1,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnswerWidget(question: question, onAnswerSubmitted: (_) {}),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    for (var index = 1; index <= 4; index++) {
      expect(find.text('Seçenek $index'), findsOneWidget);
    }
  });
}
