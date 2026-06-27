import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/network/connectivity_provider.dart';
import 'core/services/sound_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/ad_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/child_profile/providers/selected_child_provider.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        upgrader: Upgrader(
          durationUntilAlertAgain: const Duration(days: 3),
          languageCode: 'tr',
          countryCode: 'tr',
          // Zorunlu güncelleme: aşağıdaki satırı açıp versiyon numarasını yaz.
          // Bu versiyonun altındaki kullanıcılar uygulamayı kullanamaz.
          // minAppVersion: '1.2.6',
        ),
        dialogStyle: UpgradeDialogStyle.cupertino,
        // Zorunlu güncelleme: aşağıdaki satırı açınca "Daha Sonra" butonu kaybolur.
        // canDismissDialog: false,
        child: _OfflineBanner(child: child!),
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
