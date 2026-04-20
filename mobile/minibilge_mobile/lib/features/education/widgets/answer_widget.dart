import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/question.dart';

class AnswerWidget extends StatefulWidget {
  final Question question;
  final Function(String) onAnswerSubmitted;

  const AnswerWidget({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  State<AnswerWidget> createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  String? _selectedAnswer;
  final TextEditingController _textController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void didUpdateWidget(AnswerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Yeni soru geldiğinde state'i sıfırla
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _selectedAnswer = null;
        _textController.clear();
        _isSubmitted = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    String? answer;
    
    switch (widget.question.questionType) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        answer = _selectedAnswer;
        break;
      case QuestionType.numericInput:
        answer = _textController.text.trim();
        break;
    }

    if (answer != null && answer.isNotEmpty && !_isSubmitted) {
      setState(() {
        _isSubmitted = true;
      });
      widget.onAnswerSubmitted(answer);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.question.questionType) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoice();
      case QuestionType.trueFalse:
        return _buildTrueFalse();
      case QuestionType.numericInput:
        return _buildNumericInput();
    }
  }

  Widget _buildMultipleChoice() {
    final options = widget.question.options;
    final optionLetters = ['A', 'B', 'C', 'D'];

    return Column(
      children: [
        ...List.generate(options.length, (index) {
          final option = options[index];
          final letter = optionLetters[option.displayOrder];
          final isSelected = _selectedAnswer == letter;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: _isSubmitted
                  ? null
                  : () {
                      setState(() {
                        _selectedAnswer = letter;
                      });
                    },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option.optionText,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedAnswer == null || _isSubmitted ? null : _submitAnswer,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitted
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Cevapla',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalse() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _isSubmitted
                    ? null
                    : () {
                        setState(() {
                          _selectedAnswer = 'Doğru';
                        });
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedAnswer == 'Doğru'
                        ? Colors.green[100]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedAnswer == 'Doğru'
                          ? Colors.green
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 48,
                        color: _selectedAnswer == 'Doğru'
                            ? Colors.green
                            : Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Doğru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: _isSubmitted
                    ? null
                    : () {
                        setState(() {
                          _selectedAnswer = 'Yanlış';
                        });
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedAnswer == 'Yanlış'
                        ? Colors.red[100]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedAnswer == 'Yanlış'
                          ? Colors.red
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cancel,
                        size: 48,
                        color: _selectedAnswer == 'Yanlış'
                            ? Colors.red
                            : Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Yanlış',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedAnswer == null || _isSubmitted ? null : _submitAnswer,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitted
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Cevapla',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumericInput() {
    return Column(
      children: [
        TextField(
          controller: _textController,
          enabled: !_isSubmitted,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            setState(() {}); // Rebuild widget when text changes
          },
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Cevabınızı yazın',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _textController.text.isEmpty || _isSubmitted ? null : _submitAnswer,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitted
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Cevapla',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }
}
