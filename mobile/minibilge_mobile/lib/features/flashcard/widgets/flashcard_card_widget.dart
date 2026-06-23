import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/tts_service.dart';
import '../models/flashcard_models.dart';

class FlashcardCardWidget extends StatefulWidget {
  final FlashcardItem card;
  final bool isFlipped;
  final VoidCallback onTap;

  const FlashcardCardWidget({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.onTap,
  });

  @override
  State<FlashcardCardWidget> createState() => _FlashcardCardWidgetState();
}

class _FlashcardCardWidgetState extends State<FlashcardCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _animation.addListener(() {
      final newShowBack = _animation.value >= 0.5;
      if (newShowBack != _showBack) {
        setState(() => _showBack = newShowBack);
      }
    });
  }

  @override
  void didUpdateWidget(FlashcardCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Card changed — reset immediately without animation
    if (oldWidget.card.id != widget.card.id) {
      _controller.value = 0;
      _showBack = false;
      return;
    }
    // Flip state changed
    if (oldWidget.isFlipped != widget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final angle = _animation.value * math.pi;
          final isUnderHalf = angle < math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(angle),
            child: isUnderHalf
                ? _CardFace.front(card: widget.card)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardFace.back(card: widget.card),
                  ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card face
// ─────────────────────────────────────────────────────────────────────────────

class _CardFace extends StatefulWidget {
  final FlashcardItem card;
  final bool isFront;

  const _CardFace.front({required this.card}) : isFront = true;
  const _CardFace.back({required this.card}) : isFront = false;

  @override
  State<_CardFace> createState() => _CardFaceState();
}

class _CardFaceState extends State<_CardFace> {
  bool _isPlaying = false;
  StreamSubscription<void>? _ttsSub;

  static const _frontGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
  );

  static const _backGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A148C), Color(0xFF1A237E)],
  );

  Future<void> _speak() async {
    if (_isPlaying) {
      await TtsService.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isPlaying = true);
    _ttsSub?.cancel();
    _ttsSub = TtsService.onCompleted.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
      _ttsSub?.cancel();
    });
    await TtsService.speak(widget.card.frontText, language: 'en');
  }

  @override
  void dispose() {
    _ttsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 260),
      decoration: BoxDecoration(
        gradient: widget.isFront ? _frontGradient : _backGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(28),
      child: widget.isFront ? _buildFront() : _buildBack(),
    );
  }

  Widget _buildFront() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tap hint
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.touch_app_rounded,
                color: Colors.white.withOpacity(0.4), size: 18),
            const SizedBox(width: 4),
            Text('Çevirmek için dokun',
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 24),
        // Front text (English word / phrase)
        Text(
          widget.card.frontText,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 20),
        // Pronunciation button
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _speak,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _isPlaying
                  ? Colors.white.withOpacity(0.35)
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _isPlaying
                    ? Colors.white.withOpacity(0.8)
                    : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPlaying ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  'Dinle',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Level badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('İngilizce',
              style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white54)),
        ),
      ],
    );
  }

  Widget _buildBack() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Turkish meaning
        Text(
          widget.card.backText,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        if (widget.card.exampleSentence != null &&
            widget.card.exampleSentence!.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Örnek cümle',
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white38)),
                const SizedBox(height: 6),
                Text(
                  widget.card.exampleSentence!,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('Türkçe',
              style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white54)),
        ),
      ],
    );
  }
}
