import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minibilge_mobile/core/data/badge_catalog.dart';
import 'package:minibilge_mobile/core/widgets/badge_earned_overlay.dart';

void main() {
  // Tekrarlayan pulse/shimmer animasyonları olduğu için pumpAndSettle yerine
  // giriş geçişini tamamlayacak kadar sabit süreli pump kullanılır.
  Future<void> triggerOverlay(
    WidgetTester tester,
    void Function(BuildContext context) action,
  ) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    action(capturedContext);
    await tester.pump(); // showGeneralDialog başlat
    await tester.pump(const Duration(milliseconds: 500)); // giriş geçişini bitir
  }

  testWidgets('showByKey katalogdaki ad, açıklama ve nadirliği gösterir', (
    tester,
  ) async {
    final meta = badgeMetaFor('speed_train')!;

    await triggerOverlay(
      tester,
      (context) => unawaited(
        BadgeEarnedOverlay.showByKey(
          context,
          'speed_train',
          showCollectionAction: false,
        ),
      ),
    );

    expect(find.text('🎉 YENİ ROZET KAZANILDI!'), findsOneWidget);
    expect(find.text(meta.name), findsOneWidget);
    expect(find.text(meta.description), findsOneWidget);
    expect(find.text('🥇 Altın Rozet'), findsOneWidget);
    // showCollectionAction: false iken aksiyon gizli olmalı.
    expect(find.text('Rozetlerimde Gör 🏅'), findsNothing);
  });

  testWidgets('showByKey bilinmeyen anahtarda hiçbir overlay açmaz', (
    tester,
  ) async {
    await triggerOverlay(
      tester,
      (context) => unawaited(
        BadgeEarnedOverlay.showByKey(
          context,
          'bilinmeyen_rozet',
          showCollectionAction: false,
        ),
      ),
    );

    expect(find.text('🎉 YENİ ROZET KAZANILDI!'), findsNothing);
  });

  testWidgets('showCollectionAction açıkken "Rozetlerimde Gör" aksiyonu görünür', (
    tester,
  ) async {
    await triggerOverlay(
      tester,
      (context) => unawaited(BadgeEarnedOverlay.showByKey(context, 'first_quiz')),
    );

    expect(find.text('Rozetlerimde Gör 🏅'), findsOneWidget);
  });
}
