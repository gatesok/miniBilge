import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFF7EC8F0),
              Color(0xFFAA9FE8),
              Color(0xFFC4A8E2),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating math symbols
              const Positioned.fill(
                child: IgnorePointer(child: _HomeFloatingSymbols()),
              ),
              // Main content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Logo / Title ───────────────────────
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '🧠',
                            style: TextStyle(fontSize: 56),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'MİNİ BİLGE',
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 50,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(3, 3)),
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(-1, -1)),
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(3, -1)),
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(-1, 3)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Eğlenerek öğren, yarışarak kazan!',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 36),

                      // ── User greeting ──────────────────────
                      authState.maybeWhen(
                        authenticated: (user) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.45),
                                width: 1.5),
                          ),
                          child: Text(
                            '👋 Merhaba, ${user.parentProfile?.firstName ?? 'Hoş Geldin'}!',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 24),

                      // ── Logout button ──────────────────────
                      GestureDetector(
                        onTap: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) context.go('/login');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7F2407),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 15),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFFF7043),
                                  Color(0xFFBF360C)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.logout_rounded,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  'ÇIKIŞ YAP',
                                  style: GoogleFonts.luckiestGuy(
                                    fontSize: 18,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black
                                            .withOpacity(0.25),
                                        offset: const Offset(1, 2),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Floating symbols for home screen
// ─────────────────────────────────────────────────────────────
class _HomeFloatingSymbols extends StatelessWidget {
  const _HomeFloatingSymbols();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _sym('+', 52, -0.3, 10, 80, Colors.yellow),
        _sym('×', 38, 0.4, null, 60, Colors.pinkAccent, right: 12),
        _sym('÷', 44, 0.15, 20, 260, Colors.lightGreenAccent),
        _sym('=', 32, -0.2, null, 240, Colors.orange, right: 18),
        _sym('+', 28, 0.35, null, 480, Colors.cyanAccent, right: 10),
        _sym('×', 46, -0.1, 16, 520, Colors.yellow),
      ],
    );
  }

  Widget _sym(
    String s,
    double size,
    double angle,
    double? left,
    double top,
    Color color, {
    double? right,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: Transform.rotate(
        angle: angle,
        child: Text(
          s,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            color: color.withOpacity(0.28),
          ),
        ),
      ),
    );
  }
}
