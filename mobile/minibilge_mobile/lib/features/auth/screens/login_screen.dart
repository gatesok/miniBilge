import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../../../core/utils/form_validators.dart';
import '../../child_profile/providers/child_profile_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    ref.listen<AuthState>(authProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        authenticated: (user) async {
          await ref.read(childProfileProvider.notifier).loadProfiles();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hoşgeldiniz ${user.email}!'),
                backgroundColor: const Color(0xFF43A047),
              ),
            );
          }
        },
        unauthenticated: () {},
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: const Color(0xFFD32F2F),
            ),
          );
          ref.read(authProvider.notifier).clearError();
        },
      );
    });

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
                child: IgnorePointer(child: _LoginFloatingSymbols()),
              ),
              // Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Logo ────────────────────────────
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.28),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('🧠',
                                    style: TextStyle(fontSize: 52)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Title ────────────────────────────
                          Text(
                            'MİNİ BİLGE',
                            style: GoogleFonts.luckiestGuy(
                              fontSize: 44,
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
                          const SizedBox(height: 6),

                          Text(
                            'Ebeveyn Girişi',
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 36),

                          // ── Email Field ──────────────────────
                          _GameInputField(
                            controller: _emailController,
                            hint: 'Email',
                            emoji: '✉️',
                            keyboardType: TextInputType.emailAddress,
                            validator: FormValidators.validateEmail,
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 14),

                          // ── Password Field ───────────────────
                          _GameInputField(
                            controller: _passwordController,
                            hint: 'Şifre',
                            emoji: '🔒',
                            obscureText: _obscurePassword,
                            validator: FormValidators.validatePassword,
                            enabled: !isLoading,
                            suffixIcon: GestureDetector(
                              onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF2D1B69).withOpacity(0.6),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Login Button ─────────────────────
                          if (isLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            )
                          else
                            _GameActionButton(
                              label: 'GİRİŞ YAP',
                              emoji: '🚀',
                              onTap: _handleLogin,
                              gradientColors: const [
                                Color(0xFF7B61FF),
                                Color(0xFF4A3ABA),
                              ],
                              shadowColor: const Color(0xFF2E2280),
                            ),
                          const SizedBox(height: 12),

                          // ── Forgot Password Link ─────────────
                          Center(
                            child: GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => context.go('/forgot-password'),
                              child: Text(
                                'Şifremi unuttum',
                                style: GoogleFonts.nunito(
                                  color: Colors.white.withOpacity(0.75),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      Colors.white.withOpacity(0.75),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Register Link ────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Hesabınız yok mu? ',
                                style: GoogleFonts.nunito(
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () => context.go('/register'),
                                child: Text(
                                  'Kayıt Ol',
                                  style: GoogleFonts.nunito(
                                    color: const Color(0xFFFFCA28),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // ── Test User Card ───────────────────
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                  width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🧪 Test Kullanıcısı:',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Email: test@test.com',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Şifre: Test1234!',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
//  GAME INPUT FIELD  (frosted-glass style)
// ─────────────────────────────────────────────────────────────
class _GameInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String emoji;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool obscureText;
  final Widget? suffixIcon;

  const _GameInputField({
    required this.controller,
    required this.hint,
    required this.emoji,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: Colors.white.withOpacity(0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        validator: validator,
        style: GoogleFonts.nunito(
          color: const Color(0xFF2D1B69),
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.nunito(
            color: const Color(0xFF2D1B69).withOpacity(0.45),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Text(emoji,
                style: const TextStyle(fontSize: 20)),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 18),
          errorStyle: GoogleFonts.nunito(
            color: const Color(0xFFFFCA28),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  GAME ACTION BUTTON  (3-D pill style)
// ─────────────────────────────────────────────────────────────
class _GameActionButton extends StatelessWidget {
  final String label;
  final String emoji;
  final VoidCallback onTap;
  final List<Color> gradientColors;
  final Color shadowColor;

  const _GameActionButton({
    required this.label,
    required this.emoji,
    required this.onTap,
    required this.gradientColors,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.18),
                offset: const Offset(0, -3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.luckiestGuy(
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FLOATING SYMBOLS  (login screen)
// ─────────────────────────────────────────────────────────────
class _LoginFloatingSymbols extends StatelessWidget {
  const _LoginFloatingSymbols();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _sym('+', 52, -0.25, 10, 80, Colors.yellow),
        _sym('×', 36, 0.35, null, 65, Colors.pinkAccent, right: 14),
        _sym('÷', 44, 0.12, 18, 310, Colors.lightGreenAccent),
        _sym('=', 32, -0.18, null, 280, Colors.orange, right: 16),
        _sym('+', 28, 0.40, null, 530, Colors.cyanAccent, right: 10),
        _sym('×', 42, -0.15, 14, 580, Colors.yellow),
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
