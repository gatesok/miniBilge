import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/external_login_status.dart';
import '../providers/auth_service_provider.dart';

class LinkedAccountsScreen extends ConsumerStatefulWidget {
  const LinkedAccountsScreen({super.key});

  @override
  ConsumerState<LinkedAccountsScreen> createState() =>
      _LinkedAccountsScreenState();
}

class _LinkedAccountsScreenState extends ConsumerState<LinkedAccountsScreen> {
  ExternalLoginStatus? _status;
  bool _loading = true;
  String? _activeProvider;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    try {
      final status = await ref
          .read(authApiServiceProvider)
          .getExternalLoginStatus();
      if (!mounted) return;
      setState(() {
        _status = status;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Bağlı hesaplar yüklenemedi', isError: true);
    }
  }

  Future<void> _toggle(String provider) async {
    final status = _status;
    if (status == null || _activeProvider != null) return;

    if (status.isLinked(provider)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: const Icon(
            Icons.link_off_rounded,
            color: Color(0xFF6C55E1),
            size: 34,
          ),
          title: Text(
            '$provider bağlantısını kaldır',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Bu giriş yöntemini kaldırmak istediğinizden emin misiniz?',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6C55E1),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Kaldır'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _activeProvider = provider);
    try {
      final api = ref.read(authApiServiceProvider);
      final identity = ref.read(externalIdentityServiceProvider);

      if (status.isLinked(provider)) {
        await api.unlinkExternalLogin(provider);
      } else if (provider == 'Google') {
        await api.linkGoogle(await identity.getGoogleIdToken());
      } else {
        final credential = await identity.getAppleCredential();
        await api.linkApple(
          identityToken: credential.identityToken,
          authorizationCode: credential.authorizationCode,
          nonce: credential.rawNonce,
          firstName: credential.firstName,
          lastName: credential.lastName,
        );
      }

      await _load();
      if (mounted) {
        _showMessage(
          status.isLinked(provider)
              ? '$provider bağlantısı kaldırıldı'
              : '$provider hesabı bağlandı',
        );
      }
    } catch (error) {
      if (mounted) {
        _showMessage(
          error.toString().contains('ExternalSignInCancelledException')
              ? 'İşlem iptal edildi'
              : 'İşlem tamamlanamadı',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _activeProvider = null);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFD32F2F)
            : const Color(0xFF43A047),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.55, 1],
            colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _Header(onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF6C55E1),
                        onRefresh: _load,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.38),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(11),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.security_rounded,
                                      color: Color(0xFF5D45D6),
                                      size: 27,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Giriş yöntemleri',
                                          style: GoogleFonts.nunito(
                                            color: Colors.white,
                                            fontSize: 23,
                                            fontWeight: FontWeight.w900,
                                            shadows: const [
                                              Shadow(
                                                color: Color(0x33000000),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Hesabına bağlı giriş yöntemlerini güvenle yönet.',
                                          style: GoogleFonts.nunito(
                                            color: Colors.white.withValues(
                                              alpha: 0.92,
                                            ),
                                            height: 1.35,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _ProviderTile(
                              title: 'Google',
                              subtitle: 'Google hesabınla hızlı giriş',
                              icon: 'G',
                              linked: _status?.isLinked('Google') ?? false,
                              loading: _activeProvider == 'Google',
                              onTap: () => _toggle('Google'),
                              accentColor: const Color(0xFF4285F4),
                            ),
                            if (isIos) ...[
                              const SizedBox(height: 14),
                              _ProviderTile(
                                title: 'Apple',
                                subtitle: 'Apple kimliğinle güvenli giriş',
                                icon: '',
                                linked: _status?.isLinked('Apple') ?? false,
                                loading: _activeProvider == 'Apple',
                                onTap: () => _toggle('Apple'),
                                accentColor: const Color(0xFF29233A),
                              ),
                            ],
                            const SizedBox(height: 14),
                            _ProviderTile(
                              title: 'E-posta ve şifre',
                              subtitle: 'Klasik giriş yöntemin',
                              icon: '@',
                              linked: _status?.hasPassword ?? false,
                              onTap: null,
                              accentColor: const Color(0xFF7B61FF),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF352B72,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Hesabında en az bir giriş yöntemi kalmalıdır. Son giriş yöntemi kaldırılamaz.',
                                      style: GoogleFonts.nunito(
                                        color: Colors.white,
                                        fontSize: 13,
                                        height: 1.35,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
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

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Material(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Bağlı Hesaplar',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
                shadows: const [
                  Shadow(
                    color: Color(0x33000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.link_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.title,
    required this.icon,
    required this.linked,
    required this.onTap,
    required this.subtitle,
    required this.accentColor,
    this.loading = false,
  });

  final String title;
  final String subtitle;
  final String icon;
  final bool linked;
  final bool loading;
  final VoidCallback? onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: linked
              ? const Color(0xFF55C879).withValues(alpha: 0.55)
              : Colors.white,
          width: linked ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF463A91).withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                icon,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF28223F),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF756F88),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: linked
                        ? const Color(0xFFE7F8EC)
                        : const Color(0xFFF0EDF8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    linked ? '●  Bağlı' : '○  Bağlı değil',
                    style: GoogleFonts.nunito(
                      color: linked
                          ? const Color(0xFF258D47)
                          : const Color(0xFF756F88),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (loading)
            const SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF6C55E1),
              ),
            )
          else if (onTap == null)
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFE7F8EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF37A85A),
                size: 24,
              ),
            )
          else
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                elevation: 0,
                backgroundColor: linked
                    ? const Color(0xFFF1EEFA)
                    : const Color(0xFF6C55E1),
                foregroundColor: linked
                    ? const Color(0xFF6C55E1)
                    : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: Text(linked ? 'Kaldır' : 'Bağla'),
            ),
        ],
      ),
    );
  }
}
