import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Ek çocuk profili Premium gerektirir; onaylanırsa premium ekranına yönlendirir.
Future<void> showAdditionalProfilePaywall(BuildContext context) async {
  final goPremium = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Ek profil Premium ile'),
      content: const Text(
        'Ücretsiz üyelikte tek çocuk profili oluşturabilirsin. '
        'Ailedeki diğer çocuklar için ek profiller Premium ile açılır.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('✨ Premium\'a Geç'),
        ),
      ],
    ),
  );
  if (goPremium == true && context.mounted) {
    context.push('/premium');
  }
}
