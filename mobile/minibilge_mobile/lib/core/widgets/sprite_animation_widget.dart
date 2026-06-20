import 'package:flutter/material.dart';

/// Sprite sheet enum — her animasyon türü için frame sayısı ve asset path.
enum HeroAnimation {
  idle(asset: 'assets/sprites/male_hero-idle.png', frameCount: 10),
  walk(asset: 'assets/sprites/male_hero-walk.png', frameCount: 10),
  run(asset: 'assets/sprites/male_hero-run.png', frameCount: 10),
  jump(asset: 'assets/sprites/male_hero-jump.png', frameCount: 6),
  fall(asset: 'assets/sprites/male_hero-fall.png', frameCount: 4),
  fallLoop(asset: 'assets/sprites/male_hero-fall_loop.png', frameCount: 3),
  combo(asset: 'assets/sprites/male_hero-combo_1.png', frameCount: 3),
  comboEnd(asset: 'assets/sprites/male_hero-combo_1_end.png', frameCount: 4);

  final String asset;
  final int frameCount;
  const HeroAnimation({required this.asset, required this.frameCount});
}

/// Sprite sheet animasyon widget'ı.
///
/// Tek PNG dosyası içindeki kareleri sırayla göstererek animasyon yaratır.
/// Frame boyutu kare (frameSize × frameSize) varsayılır — her sheet 128×128 karetir.
///
/// Kullanım:
/// ```dart
/// SpriteAnimationWidget(
///   animation: HeroAnimation.walk,
///   size: 96,
///   fps: 12,
/// )
/// ```
class SpriteAnimationWidget extends StatefulWidget {
  final HeroAnimation animation;

  /// Ekranda gösterilecek boyut (piksel). Oransal büyütme/küçültme.
  final double size;

  /// Saniyedeki frame sayısı
  final int fps;

  /// Animasyonu tekrar et
  final bool loop;

  /// Animasyon bitince callback
  final VoidCallback? onComplete;

  const SpriteAnimationWidget({
    super.key,
    required this.animation,
    this.size = 64,
    this.fps = 10,
    this.loop = true,
    this.onComplete,
  });

  @override
  State<SpriteAnimationWidget> createState() =>
      _SpriteAnimationWidgetState();
}

class _SpriteAnimationWidgetState extends State<SpriteAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentFrame = 0;

  @override
  void initState() {
    super.initState();
    _setupController();
  }

  void _setupController() {
    final duration = Duration(
        milliseconds: (1000 / widget.fps * widget.animation.frameCount).round());

    _controller = AnimationController(vsync: this, duration: duration);

    _controller.addListener(() {
      final frame = (_controller.value * widget.animation.frameCount)
          .floor()
          .clamp(0, widget.animation.frameCount - 1);
      if (frame != _currentFrame && mounted) {
        setState(() => _currentFrame = frame);
      }
    });

    if (widget.loop) {
      _controller.repeat();
    } else {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void didUpdateWidget(SpriteAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation ||
        oldWidget.fps != widget.fps) {
      _controller.dispose();
      _currentFrame = 0;
      _setupController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.animation.frameCount;
    // Alignment.x: -1 (ilk frame solda) → +1 (son frame sağda)
    final alignX = n == 1 ? 0.0 : -1.0 + 2.0 * _currentFrame / (n - 1);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipRect(
        child: Align(
          alignment: Alignment(alignX, 0),
          widthFactor: 1 / n,
          child: Image.asset(
            widget.animation.asset,
            height: widget.size,
            fit: BoxFit.fitHeight,
            filterQuality: FilterQuality.none, // pixel art için keskin kenар
          ),
        ),
      ),
    );
  }
}

/// Animasyonu programatik olarak kontrol etmek için controller.
/// Kullanım:
/// ```dart
/// final ctrl = SpriteController();
/// SpriteAnimationWidget(controller: ctrl, ...)
/// ctrl.playOnce(HeroAnimation.jump, onComplete: () => ctrl.play(HeroAnimation.idle));
/// ```
class SpriteController extends ChangeNotifier {
  HeroAnimation _animation = HeroAnimation.idle;
  bool _loop = true;
  VoidCallback? _onComplete;

  HeroAnimation get animation => _animation;
  bool get loop => _loop;
  VoidCallback? get onComplete => _onComplete;

  void play(HeroAnimation anim) {
    _animation = anim;
    _loop = true;
    _onComplete = null;
    notifyListeners();
  }

  void playOnce(HeroAnimation anim, {VoidCallback? onComplete}) {
    _animation = anim;
    _loop = false;
    _onComplete = onComplete;
    notifyListeners();
  }
}

/// SpriteController ile çalışan gelişmiş widget.
class ControlledSpriteWidget extends StatefulWidget {
  final SpriteController controller;
  final double size;
  final int fps;

  const ControlledSpriteWidget({
    super.key,
    required this.controller,
    this.size = 64,
    this.fps = 10,
  });

  @override
  State<ControlledSpriteWidget> createState() =>
      _ControlledSpriteWidgetState();
}

class _ControlledSpriteWidgetState extends State<ControlledSpriteWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpriteAnimationWidget(
      animation: widget.controller.animation,
      size: widget.size,
      fps: widget.fps,
      loop: widget.controller.loop,
      onComplete: widget.controller.onComplete,
    );
  }
}
