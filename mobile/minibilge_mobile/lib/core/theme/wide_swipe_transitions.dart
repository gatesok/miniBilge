import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// CupertinoPageTransition animasyonunu korurken gesture alanını genişletir.
/// Sol kenar yerine ekranın tamamından sağa swipe ile bir önceki sayfaya dönülür.
class WideSwipePageTransitionsBuilder extends PageTransitionsBuilder {
  const WideSwipePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: false,
      child: _WideSwipeBackDetector(
        route: route,
        child: child,
      ),
    );
  }
}

class _WideSwipeBackDetector extends StatefulWidget {
  final PageRoute<dynamic> route;
  final Widget child;

  const _WideSwipeBackDetector({required this.route, required this.child});

  @override
  State<_WideSwipeBackDetector> createState() => _WideSwipeBackDetectorState();
}

class _WideSwipeBackDetectorState extends State<_WideSwipeBackDetector> {
  double? _dragStartX;

  /// Aktif oyun/quiz/yarışma ekranlarında swipe-back devre dışı.
  /// GoRouter route.settings.name = GoRoute'un 'name' özelliği (path değil!).
  static const _swipeDisabledRouteNames = {
    // Canlı yarışma
    'match-arena',
    'match-request',
    // Eğlence oyunları
    'entertainment-quiz',
    'entertainment-fact-fiction',
    'entertainment-kim-bu',
    'entertainment-ne-ortak',
    // AI Quiz
    'adaptive-quiz',
    // Meydan okuma quiz
    'challenge-quiz',
    // Matematik / İngilizce soru ekranları
    'education-quiz',
    'education-quiz-result',
    // Flashcard çalışma
    'flashcard-study',
    // Podcast quizi
    'podcast-quiz',
  };

  bool get _canPop {
    final NavigatorState? navigator = widget.route.navigator;
    if (navigator == null || !navigator.canPop()) return false;

    final routeName = widget.route.settings.name ?? '';
    if (_swipeDisabledRouteNames.contains(routeName)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (details) {
              _dragStartX = details.globalPosition.dx;
            },
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              final dragDx = details.globalPosition.dx - (_dragStartX ?? 0);
              _dragStartX = null;

              if (_canPop && (velocity > 300 || (velocity > 0 && dragDx > 100))) {
                Navigator.of(context).maybePop();
              }
            },
          ),
        ),
      ],
    );
  }
}
