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
          title: Text('$provider bağlantısını kaldır'),
          content: const Text(
            'Bu giriş yöntemini kaldırmak istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
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
      appBar: AppBar(title: const Text('Bağlı Hesaplar')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Giriş yöntemleri',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hesabınıza bağlı giriş yöntemlerini buradan yönetebilirsiniz.',
                    style: GoogleFonts.nunito(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ProviderTile(
                    title: 'Google',
                    icon: 'G',
                    linked: _status?.isLinked('Google') ?? false,
                    loading: _activeProvider == 'Google',
                    onTap: () => _toggle('Google'),
                  ),
                  if (isIos) ...[
                    const SizedBox(height: 12),
                    _ProviderTile(
                      title: 'Apple',
                      icon: '',
                      linked: _status?.isLinked('Apple') ?? false,
                      loading: _activeProvider == 'Apple',
                      onTap: () => _toggle('Apple'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _ProviderTile(
                    title: 'E-posta ve şifre',
                    icon: '@',
                    linked: _status?.hasPassword ?? false,
                    onTap: null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Hesabınızda en az bir giriş yöntemi kalmalıdır. Son giriş yöntemi kaldırılamaz.',
                    style: GoogleFonts.nunito(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
    this.loading = false,
  });

  final String title;
  final String icon;
  final bool linked;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEDE7FF),
          child: Text(
            icon,
            style: const TextStyle(
              color: Color(0xFF4A3ABA),
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(linked ? 'Bağlı' : 'Bağlı değil'),
        trailing: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : onTap == null
            ? Icon(
                linked ? Icons.check_circle : Icons.info_outline,
                color: linked ? Colors.green : Colors.grey,
              )
            : TextButton(
                onPressed: onTap,
                child: Text(linked ? 'Kaldır' : 'Bağla'),
              ),
      ),
    );
  }
}
