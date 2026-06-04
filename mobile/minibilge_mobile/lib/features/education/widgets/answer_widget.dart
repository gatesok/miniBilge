import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question.dart';
import '../../../shared/widgets/math_text_widget.dart';

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

  // Colors for each option A, B, C, D
  static const _optionColors = [
    Color(0xFF3498DB), // A - blue
    Color(0xFF2ECC71), // B - green
    Color(0xFFE67E22), // C - orange
    Color(0xFF9B59B6), // D - purple
  ];

  @override
  void didUpdateWidget(AnswerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
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

    return Column(
      children: [
        ...List.generate(options.length, (index) {
          final option = options[index];
          final optionLetters = ['A', 'B', 'C', 'D'];
          final letter = optionLetters[option.displayOrder];
          final isSelected = _selectedAnswer == letter;
          final color = _optionColors[option.displayOrder % _optionColors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: _isSubmitted
                  ? null
                  : () {
                      setState(() {
                        _selectedAnswer = letter;
                      });
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.4)
                      : Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? color.withOpacity(0.9)
                        : Colors.white.withOpacity(0.35),
                    width: isSelected ? 2.5 : 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      // Letter badge
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color
                              : color.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: color.withOpacity(0.7), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: GoogleFonts.luckiestGuy(
                                fontSize: 18,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                      blurRadius: 0,
                                      color: Color(0xFF3D35CC),
                                      offset: Offset(1, 1))
                                ]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MathText(
                          text: option.optionText,
                          hasLatex: option.hasLatex,
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                              fontSize: 16),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        _SubmitButton(
          onTap: _selectedAnswer == null || _isSubmitted ? null : _submitAnswer,
          isSubmitted: _isSubmitted,
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
              child: GestureDetector(
                onTap: _isSubmitted
                    ? null
                    : () {
                        setState(() {
                          _selectedAnswer = 'Doğru';
                        });
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 110,
                  decoration: BoxDecoration(
                    color: _selectedAnswer == 'Doğru'
                        ? Colors.green.withOpacity(0.4)
                        : Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _selectedAnswer == 'Doğru'
                          ? Colors.green.withOpacity(0.9)
                          : Colors.white.withOpacity(0.35),
                      width: _selectedAnswer == 'Doğru' ? 2.5 : 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '✅',
                        style: TextStyle(
                            fontSize:
                                _selectedAnswer == 'Doğru' ? 44 : 36),
                      ),
                      const SizedBox(height: 8),
                      Text('DOĞRU',
                          style: GoogleFonts.luckiestGuy(
                              fontSize: 18,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                    blurRadius: 0,
                                    color: Color(0xFF3D35CC),
                                    offset: Offset(1, 1))
                              ])),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GestureDetector(
                onTap: _isSubmitted
                    ? null
                    : () {
                        setState(() {
                          _selectedAnswer = 'Yanlış';
                        });
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 110,
                  decoration: BoxDecoration(
                    color: _selectedAnswer == 'Yanlış'
                        ? Colors.red.withOpacity(0.4)
                        : Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _selectedAnswer == 'Yanlış'
                          ? Colors.red.withOpacity(0.9)
                          : Colors.white.withOpacity(0.35),
                      width: _selectedAnswer == 'Yanlış' ? 2.5 : 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '❌',
                        style: TextStyle(
                            fontSize:
                                _selectedAnswer == 'Yanlış' ? 44 : 36),
                      ),
                      const SizedBox(height: 8),
                      Text('YANLIŞ',
                          style: GoogleFonts.luckiestGuy(
                              fontSize: 18,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                    blurRadius: 0,
                                    color: Color(0xFF3D35CC),
                                    offset: Offset(1, 1))
                              ])),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SubmitButton(
          onTap: _selectedAnswer == null || _isSubmitted ? null : _submitAnswer,
          isSubmitted: _isSubmitted,
        ),
      ],
    );
  }

  Widget _buildNumericInput() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.white.withOpacity(0.45), width: 1.5),
          ),
          child: TextField(
            controller: _textController,
            enabled: !_isSubmitted,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => setState(() {}),
            style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Cevabınızı yazın',
              hintStyle: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _SubmitButton(
          onTap: _textController.text.isEmpty || _isSubmitted
              ? null
              : _submitAnswer,
          isSubmitted: _isSubmitted,
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isSubmitted;

  const _SubmitButton({required this.onTap, required this.isSubmitted});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          width: double.infinity,
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFF3D35CC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF7B61FF), Color(0xFF9B59B6)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: isSubmitted
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'CEVAPLA 🚀',
                      style: GoogleFonts.luckiestGuy(
                          fontSize: 20,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(2, 2))
                          ]),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
