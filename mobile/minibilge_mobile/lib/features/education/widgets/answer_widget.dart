import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question.dart';
import '../models/submit_answer_response.dart';

class AnswerWidget extends StatefulWidget {
  final Question question;
  final Function(String) onAnswerSubmitted;

  /// Sunucudan dönen sonuç — null ise henüz bekleniyor
  final SubmitAnswerResponse? feedbackResult;

  /// Kullanıcının gönderdiği cevap (renklemek için parent'tan geliyor)
  final String? submittedAnswer;

  const AnswerWidget({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
    this.feedbackResult,
    this.submittedAnswer,
  });

  @override
  State<AnswerWidget> createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  String? _selectedAnswer;
  final TextEditingController _textController = TextEditingController();
  bool _isSubmitted = false;

  static const _optionColors = [
    Color(0xFF3498DB),
    Color(0xFF2ECC71),
    Color(0xFFE67E22),
    Color(0xFF9B59B6),
  ];

  static const _correctColor = Color(0xFF27AE60);
  static const _wrongColor   = Color(0xFFE53935);

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

  /// MC / TF: tap = anında submit, ayrı "Cevapla" butonu yok
  void _tapAndSubmit(String answer) {
    if (_isSubmitted) return;
    setState(() {
      _selectedAnswer = answer;
      _isSubmitted = true;
    });
    widget.onAnswerSubmitted(answer);
  }

  /// NumericInput için ayrı buton
  void _submitNumeric() {
    final answer = _textController.text.trim();
    if (answer.isEmpty || _isSubmitted) return;
    setState(() => _isSubmitted = true);
    widget.onAnswerSubmitted(answer);
  }

  // ── Renk yardımcıları ────────────────────────────────────────────

  Color _optionBg(String letter, int displayOrder) {
    final fb = widget.feedbackResult;
    if (fb == null) {
      return _selectedAnswer == letter
          ? _optionColors[displayOrder % _optionColors.length]
          : Colors.white;
    }
    if (letter == fb.correctAnswer) return _correctColor;
    if (letter == widget.submittedAnswer && !fb.isCorrect) return _wrongColor;
    return const Color(0xFFEEEEEE);
  }

  Color _optionText(String letter) {
    final fb = widget.feedbackResult;
    if (fb == null) {
      return _selectedAnswer == letter ? Colors.white : const Color(0xFF1A1A2E);
    }
    if (letter == fb.correctAnswer) return Colors.white;
    if (letter == widget.submittedAnswer && !fb.isCorrect) return Colors.white;
    return const Color(0xFFBDBDBD);
  }

  Widget? _trailingIcon(String letter) {
    final fb = widget.feedbackResult;
    if (fb == null) {
      return _selectedAnswer == letter
          ? Icon(Icons.check_circle_rounded, color: Colors.white.withOpacity(0.9), size: 22)
          : null;
    }
    if (letter == fb.correctAnswer) {
      return const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24);
    }
    if (letter == widget.submittedAnswer && !fb.isCorrect) {
      return const Icon(Icons.cancel_rounded, color: Colors.white, size: 24);
    }
    return null;
  }

  // ── Build ────────────────────────────────────────────────────────

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
    final letters = ['A', 'B', 'C', 'D'];
    final hasFb = widget.feedbackResult != null;

    return Column(
      children: List.generate(options.length, (i) {
        final option = options[i];
        final letter = letters[option.displayOrder];
        final bg = _optionBg(letter, option.displayOrder);
        final trailing = _trailingIcon(letter);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: _isSubmitted ? null : () => _tapAndSubmit(letter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(18),
                border: hasFb && letter == widget.feedbackResult!.correctAnswer
                    ? Border.all(color: Colors.white.withOpacity(0.55), width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: bg.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(letter,
                            style: GoogleFonts.luckiestGuy(
                                fontSize: 17, color: _optionText(letter))),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(option.optionText,
                          style: GoogleFonts.nunito(
                              color: _optionText(letter),
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                    ),
                    if (trailing != null) trailing,
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTrueFalse() {
    final fb = widget.feedbackResult;

    Color tfBg(String val) {
      if (fb == null) {
        if (_selectedAnswer == val) return val == 'Doğru' ? _correctColor : _wrongColor;
        return Colors.white;
      }
      if (val == fb.correctAnswer) return _correctColor;
      if (val == widget.submittedAnswer && !fb.isCorrect) return _wrongColor;
      return const Color(0xFFEEEEEE);
    }

    Color tfText(String val) {
      if (fb == null) return _selectedAnswer == val ? Colors.white : const Color(0xFF1A1A2E);
      if (val == fb.correctAnswer) return Colors.white;
      if (val == widget.submittedAnswer && !fb.isCorrect) return Colors.white;
      return const Color(0xFFBDBDBD);
    }

    Widget card(String val, String emoji) => Expanded(
      child: GestureDetector(
        onTap: _isSubmitted ? null : () => _tapAndSubmit(val),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 110,
          decoration: BoxDecoration(
            color: tfBg(val),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: TextStyle(fontSize: _selectedAnswer == val ? 40 : 34)),
              const SizedBox(height: 8),
              Text(val.toUpperCase(),
                  style: GoogleFonts.luckiestGuy(
                      fontSize: 18,
                      color: tfText(val),
                      shadows: _selectedAnswer == val
                          ? const [Shadow(blurRadius: 0, color: Color(0x55000000), offset: Offset(1, 1))]
                          : null)),
            ],
          ),
        ),
      ),
    );

    return Row(children: [card('Doğru', '✅'), const SizedBox(width: 14), card('Yanlış', '❌')]);
  }

  Widget _buildNumericInput() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: TextField(
            controller: _textController,
            enabled: !_isSubmitted,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A2E)),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Cevabınızı yazın',
              hintStyle: GoogleFonts.nunito(color: const Color(0xFF1A1A2E).withOpacity(0.35), fontSize: 18, fontWeight: FontWeight.w600),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _SubmitButton(
          onTap: _textController.text.isEmpty || _isSubmitted ? null : _submitNumeric,
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
        opacity: isEnabled ? 1.0 : 0.45,
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFF3D35CC), borderRadius: BorderRadius.circular(50)),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF9575CD), Color(0xFF7B61FF)],
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.18), offset: const Offset(0, -3), blurRadius: 6)],
            ),
            child: Center(
              child: isSubmitted
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text('CEVAPLA 🚀',
                      style: GoogleFonts.luckiestGuy(
                          fontSize: 20,
                          color: Colors.white,
                          shadows: const [Shadow(blurRadius: 0, color: Color(0xFF3D35CC), offset: Offset(2, 2))])),
            ),
          ),
        ),
      ),
    );
  }
}
