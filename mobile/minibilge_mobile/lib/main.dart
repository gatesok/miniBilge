import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/network/connectivity_provider.dart';
import 'core/services/sound_service.dart';
import 'core/services/notification_service.dart';
import 'features/wordle/services/wordle_notification_service.dart';
import 'core/services/ad_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/child_profile/providers/selected_child_provider.dart';
import 'features/friends/providers/friend_provider.dart';
import 'features/friends/services/social_hub_service.dart';
import 'features/challenge/providers/challenge_provider.dart';

/// Global key — snackbar'ları herhangi bir context olmadan göstermek için
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr', null);

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Sound Service
  await SoundService.initialize();

  // Initialize AdMob
  await AdService.initialize();

  // Günlük Wordle bildirimi kalıcı olarak iptal et
  // (Dashboard'dan kaldırıldı — önceki kurulumlardan kalan planlanmış bildirim silinir)
  await WordleNotificationService.disableDailyReminder();

  // Create ProviderContainer early so we can access providers from the FCM callback
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );

  // Initialize push notifications in the background — do NOT await.
  // requestPermission() on iOS blocks until the user responds to the dialog,
  // which would freeze the splash screen. Token is saved to SharedPreferences
  // and registered with the backend when a child profile is selected.
  NotificationService.initialize(
    onTokenReceived: (token) async {
      await sharedPreferences.setString(StorageKeys.pendingFcmToken, token);
      try {
        await container
            .read(selectedChildProvider.notifier)
            .onNewFcmToken(token);
      } catch (_) {}
    },
    onForegroundMessage: (title, body) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.notifications, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  if (body.isNotEmpty)
                    Text(body,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ]),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          backgroundColor: const Color(0xFF323232),
        ),
      );
    },
    onNotificationTap: (RemoteMessage message) {
      final type = message.data['type'] as String?;
      final router = container.read(goRouterProvider);
      if (type == 'friend_request') {
        router.go('/friends', extra: {'tab': 1});
      } else if (type == 'match_invite') {
        router.go('/friends', extra: {'tab': 2});
      } else if (type == 'challenge_received' ||
                 type == 'challenge_accepted' ||
                 type == 'challenge_result') {
        router.go('/challenges');
      } else {
        router.go('/friends');
      }
    },
    onForegroundData: (RemoteMessage message) {
      final type = message.data['type'] as String?;
      // Push notification arrived while app is open — sync state for event types
      // that may have been missed by SignalR (different Cloud Run instance).
      if (type == 'match_invite_response' || type == 'friend_request') {
        try {
          container.read(friendProvider.notifier).syncSentInvites();
        } catch (_) {}
      }
      if (type == 'challenge_received' ||
          type == 'challenge_accepted' ||
          type == 'challenge_result') {
        try {
          container.read(challengeNotifierProvider.notifier).loadAll();
        } catch (_) {}
      }
    },
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  late final Upgrader _upgrader;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _upgrader = Upgrader(
      durationUntilAlertAgain: const Duration(hours: 4),
      languageCode: 'tr',
      countryCode: 'TR',
      debugLogging: false,
    );
    // upgrader v11+ initialize() must be called explicitly
    _upgrader.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Uygulama arka plandan öne geldiğinde token geçerliliğini kontrol et.
  /// Access token süresi dolduysa sessizce refresh yap; refresh da dolmuşsa login'e at.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Arka plandan öne gelince App Store'u tekrar kontrol et
      _upgrader.initialize().then((_) {
        if (mounted) setState(() {});
      });

      ref.read(authProvider.notifier).refreshIfNeeded();
      // FCM token kaydını da dene — uygulama açıkken token gelmişse kaydet
      final child = ref.read(selectedChildProvider);
      if (child != null) {
        ref.read(selectedChildProvider.notifier).retryFcmRegistration(child.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(goRouterProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // Router configuration
      routerConfig: router,

      // Localization — system language for date pickers etc.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
      ],

      // Global offline banner + güncelleme uyarısı
      builder: (context, child) => UpgradeAlert(
        upgrader: _upgrader,
        navigatorKey: rootNavigatorKey,   // Navigator context'ini düzgeltir
        dialogStyle: UpgradeDialogStyle.cupertino,
        child: _SocialListener(child: _OfflineBanner(child: child!)),
      ),
    );
  }
}

/// Shows a non-intrusive "İnternet bağlantısı yok" banner when device is offline.
class _OfflineBanner extends ConsumerWidget {
  const _OfflineBanner({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isOnline ? 0 : 32,
          color: Colors.red.shade700,
          child: isOnline
              ? const SizedBox.shrink()
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'İnternet bağlantısı yok',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// Uygulama genelinde SocialHub'a bağlanır ve gelen bildirimleri snackbar ile gösterir.
class _SocialListener extends ConsumerStatefulWidget {
  const _SocialListener({required this.child});
  final Widget child;

  @override
  ConsumerState<_SocialListener> createState() => _SocialListenerState();
}

class _SocialListenerState extends ConsumerState<_SocialListener>
    with WidgetsBindingObserver {
  bool _hubConnected = false;
  Timer? _disconnectTimer;
  String? _activeInviteDialogId;
  final List<StreamSubscription<dynamic>> _subs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Listen to selectedChild — bağlantıyı çocuk seçilince kur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeConnect(ref.read(selectedChildProvider)?.id);
    });
  }

  @override
  void dispose() {
    _disconnectTimer?.cancel();
    for (final s in _subs) s.cancel();
    _subs.clear();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Arka plana geçince 3 saniye bekle — resume gelirse iptal et.
      // Anlık uygulama geçişlerinde yanlış offline olmaz.
      _disconnectTimer?.cancel();
      _disconnectTimer = Timer(const Duration(seconds: 3), () {
        final hub = ref.read(socialHubServiceProvider);
        hub.disconnect();
        _hubConnected = false;
      });
    } else if (state == AppLifecycleState.detached) {
      // Uygulama tamamen kapanıyor: hemen offline sinyali gönder
      _disconnectTimer?.cancel();
      final hub = ref.read(socialHubServiceProvider);
      hub.disconnect();
      _hubConnected = false;
    } else if (state == AppLifecycleState.resumed) {
      // Timer'ı iptal et (anlık switch durumu), yeniden bağlan
      _disconnectTimer?.cancel();
      final childId = ref.read(selectedChildProvider)?.id;
      _maybeConnect(childId);
    }
  }

  void _maybeConnect(String? childId) {
    if (childId == null || _hubConnected) return;
    _hubConnected = true;
    final hub = ref.read(socialHubServiceProvider);
    hub.connect(childId).catchError((_) {
      _hubConnected = false; // retry on next child change
    });
    _subscribeStreams(hub);

    // FCM token kaydını burada da dene — hub bağlandıysa kullanıcı kesinlikle authenticated
    ref.read(selectedChildProvider.notifier).retryFcmRegistration(childId);

    // Friend provider'ı da başlat
    ref.read(friendProvider.notifier).loadPendingRequests();
    ref.read(friendProvider.notifier).loadPendingInvites();
  }

  void _subscribeStreams(SocialHubService hub) {
    // Cancel any existing subscriptions before adding new ones
    for (final s in _subs) s.cancel();
    _subs.clear();

    _subs.add(hub.onFriendRequest.listen((e) {
      _showBanner(
        icon: Icons.person_add,
        title: 'Yeni arkadaşlık isteği',
        body: '${e.requesterName} sana arkadaşlık isteği gönderdi.',
        color: const Color(0xFF5C6BC0),
      );
    }));

    _subs.add(hub.onMatchInviteResponse.listen((e) {
      if (e.accepted && e.matchSessionId != null) {
        // Future.microtask → state rebuild ile çakışmayı önler
        Future.microtask(() {
          if (mounted) {
            ref.read(goRouterProvider).go('/match/arena?matchId=${e.matchSessionId}');
          }
        });
      } else if (!e.accepted) {
        _showBanner(
          icon: Icons.cancel_outlined,
          title: 'Davet reddedildi',
          body: 'Arkadaşın daveti reddetti.',
          color: const Color(0xFFE53935),
        );
      }
    }));

    _subs.add(hub.onMatchInvite.listen((e) {
      _showMatchInviteDialog(e.invitation);
    }));

    _subs.add(hub.onMatchInviteExpired.listen((e) {
      // Eğer dialog açıksa ve bu davet için gösteriliyorsa kapat
      if (_activeInviteDialogId == e.invitationId) {
        final router = ref.read(goRouterProvider);
        final navCtx = router.routerDelegate.navigatorKey.currentContext;
        if (navCtx != null) {
          Navigator.of(navCtx, rootNavigator: true).pop();
        }
        _activeInviteDialogId = null;
      }
      _showBanner(
        icon: Icons.timer_off_outlined,
        title: 'Davet geçersiz',
        body: '${e.inviterName} ile yarışma başladı, davet süresi doldu.',
        color: const Color(0xFF7B61FF),
      );
    }));
  }

  void _showBanner({
    required IconData icon,
    required String title,
    required String body,
    required Color color,
  }) {
    scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(body,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ]),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          backgroundColor: color,
        ),
      );
  }

  void _showMatchInviteDialog(dynamic inv) {
    // Zaten bir dialog açıksa yeni dialog açma
    if (_activeInviteDialogId != null) return;
    final router = ref.read(goRouterProvider);
    final navCtx = router.routerDelegate.navigatorKey.currentContext;
    if (navCtx == null) return;
    _activeInviteDialogId = inv.id;
    showDialog(
      context: navCtx,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool _processing = false;

          Future<void> onReject() async {
            if (_processing) return;
            setDialogState(() => _processing = true);
            Navigator.of(dialogCtx).pop();
            ref.read(friendProvider.notifier).respondMatchInvite(inv.id, false);
          }

          Future<void> onAccept() async {
            if (_processing) return;
            setDialogState(() => _processing = true);
            final result = await ref
                .read(friendProvider.notifier)
                .respondMatchInvite(inv.id, true);
            if (!dialogCtx.mounted) return;
            Navigator.of(dialogCtx).pop();
            if (result?.matchSessionId != null) {
              router.push('/match/arena?matchId=${result!.matchSessionId}');
            }
          }

          return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF7B61FF).withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8))
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚡', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                'YARİŞ DEVETİ!',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 26,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                        blurRadius: 0,
                        color: Color(0xFF3D35CC),
                        offset: Offset(2, 2))
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Text(
                      '${inv.inviterName} seni yarışa davet etti!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16),
                    ),
                    if (inv.subjectName != null) ...[  
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B61FF).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          inv.subjectName!,
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _processing ? null : onReject,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(_processing ? 0.1 : 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Text('Reddet',
                            style: GoogleFonts.nunito(
                                color: _processing ? Colors.white38 : Colors.white70,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _processing ? null : onAccept,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xFFFF9800),
                          Color(0xFFFFAB00)
                        ]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFFFF9800)
                                  .withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Center(
                        child: _processing
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text('⚡ Kabul Et!',
                                style: GoogleFonts.luckiestGuy(
                                    color: Colors.white,
                                    fontSize: 16,
                                    shadows: const [
                                      Shadow(
                                          blurRadius: 0,
                                          color: Color(0xFFE65100),
                                          offset: Offset(1, 1))
                                    ])),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      );
        },
      ),
    ).then((_) {
      if (_activeInviteDialogId == inv.id) _activeInviteDialogId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Çocuk değiştiğinde hub bağlantısını başlat
    ref.listen(selectedChildProvider, (_, next) {
      if (next != null && !_hubConnected) {
        _maybeConnect(next.id);
      } else if (next == null) {
        _hubConnected = false;
        ref.read(socialHubServiceProvider).disconnect();
      }
    });
    return widget.child;
  }
}

/// Temporary Splash Screen to test theme
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Açık Tema' : 'Koyu Tema',
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [theme.colorScheme.primary, theme.colorScheme.primaryContainer]
                        : [theme.colorScheme.primary, theme.colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Name
              Text(
                AppConstants.appName,
                style: theme.textTheme.displayMedium,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Eğlenceli Öğrenme Macerası',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Theme demo card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Sprint 1 - Backend Ready! 🎉',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'API çalışıyor, veritabanı hazır.\nŞimdi frontend ekranları oluşturuyoruz!',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Navigate to Login
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Login ekranı yakında eklenecek!')),
                                );
                              },
                              child: const Text('Giriş Yap'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // TODO: Navigate to Register
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Kayıt ekranı yakında eklenecek!')),
                                );
                              },
                              child: const Text('Kayıt Ol'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Theme info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDark ? 'Koyu Tema Aktif' : 'Açık Tema Aktif',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
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
