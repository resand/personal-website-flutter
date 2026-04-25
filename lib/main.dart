import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'screens/website_screen.dart';
import 'services/config_service.dart';
import 'services/theme_service.dart';
import 'services/env_service.dart';
import 'services/preferences_service.dart';
import 'models/website_config.dart';
import 'utils/app_logger.dart';
import 'utils/theme_types.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PreferencesService.init();

  runApp(const MyWebsite());
}

class MyWebsite extends StatefulWidget {
  const MyWebsite({super.key});

  @override
  State<MyWebsite> createState() => _MyWebsiteState();
}

class _MyWebsiteState extends State<MyWebsite> with TickerProviderStateMixin {
  late ThemeModeType _themeMode;
  late AnimationController _animationController;
  MyWebsiteConfig? _config;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _themeMode = PreferencesService.getSavedTheme() ?? ThemeModeType.auto;

    _loadConfig();
  }

  ThemeModeType _parseThemeModeFromConfig(String? modeString) {
    switch (modeString?.toLowerCase()) {
      case 'light':
        return ThemeModeType.light;
      case 'dark':
        return ThemeModeType.dark;
      case 'auto':
      default:
        return ThemeModeType.auto;
    }
  }

  Future<void> _loadConfig() async {
    try {
      AppLogger.info('Loading config...');

      final loadedConfig = await ConfigService.loadConfig();

      AppLogger.success('Config loaded successfully');

      setState(() {
        _config = loadedConfig;

        if (PreferencesService.getSavedTheme() == null) {
          _themeMode = _parseThemeModeFromConfig(loadedConfig.theme.defaultMode);
        }
      });

      await _precacheAboveTheFoldImages(loadedConfig);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error loading config: $e');
      AppLogger.error('Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _precacheAboveTheFoldImages(MyWebsiteConfig config) async {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        completer.complete();
        return;
      }
      final ctx = context;

      final urls = <String>[
        config.personalInfo.avatarUrl,
        if (config.personalInfo.logoLightUrl != null) config.personalInfo.logoLightUrl!,
        if (config.personalInfo.logoDarkUrl != null) config.personalInfo.logoDarkUrl!,
      ];

      final futures = <Future<void>>[];
      for (final url in urls) {
        final provider = _imageProviderFor(url);
        if (provider == null) continue;
        futures.add(
          precacheImage(provider, ctx).catchError(
            (e) => AppLogger.warning('Precache failed for $url: $e'),
          ),
        );
      }

      await Future.wait(futures).timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () {
          AppLogger.info('Image precache timeout reached, continuing.');
          return [];
        },
      );
      completer.complete();
    });
    return completer.future;
  }

  ImageProvider? _imageProviderFor(String url) {
    if (url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    }
    if (url.startsWith('assets/')) {
      return AssetImage(url);
    }
    final webPath = url.startsWith('/') ? url : '/$url';
    return NetworkImage(webPath);
  }

  Future<void> _onLanguageChanged() async {
    try {
      final newConfig = await ConfigService.loadConfig();
      setState(() {
        _config = newConfig;
      });
    } catch (e) {
      AppLogger.error('Error reloading config after language change', e);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _cycleTheme([Offset? tapPosition]) {
    setState(() {
      switch (_themeMode) {
        case ThemeModeType.auto:
          _themeMode = ThemeModeType.light;
          break;
        case ThemeModeType.light:
          _themeMode = ThemeModeType.dark;
          break;
        case ThemeModeType.dark:
          _themeMode = ThemeModeType.auto;
          break;
      }
    });

    PreferencesService.saveTheme(_themeMode);

    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _changeTheme(ThemeModeType newTheme) {
    setState(() {
      _themeMode = newTheme;
    });

    PreferencesService.saveTheme(newTheme);
  }

  ThemeMode _getThemeMode() {
    switch (_themeMode) {
      case ThemeModeType.auto:
        return ThemeMode.system;
      case ThemeModeType.light:
        return ThemeMode.light;
      case ThemeModeType.dark:
        return ThemeMode.dark;
    }
  }

  Widget _buildLoader() {
    return _buildLottieLoader();
  }

  Widget _buildDefaultLoader() {
    final accentHex = _config?.theme.lightColors.accent;
    final color = accentHex != null
        ? Color(int.parse('FF${accentHex.replaceAll('#', '')}', radix: 16))
        : Theme.of(context).colorScheme.primary;
    return CircularProgressIndicator(
      strokeWidth: 3,
      valueColor: AlwaysStoppedAnimation<Color>(color),
    );
  }

  Widget _buildLottieLoader() {
    final bool isDarkMode = _themeMode == ThemeModeType.dark ||
        (_themeMode == ThemeModeType.auto &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);

    const String lottiePath = 'assets/lotties/loader.json';

    try {
      return _buildLottieWithDynamicColor(lottiePath, isDarkMode, false);
    } catch (e) {
      AppLogger.error('Error building Lottie loader: $e');
      return _buildDefaultLoader();
    }
  }

  Widget _buildLottieWithDynamicColor(String path, bool isDarkMode, bool isUrl) {
    final Color lottieColor = _config != null
        ? (isDarkMode
            ? Color(int.parse('FF${_config!.theme.darkColors.onSurface.replaceAll('#', '')}', radix: 16))
            : Color(int.parse('FF${_config!.theme.lightColors.onSurface.replaceAll('#', '')}', radix: 16)))
        : (isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF374151));

    return FutureBuilder<double>(
      future: EnvService.getLoaderHeight(),
      builder: (context, heightSnapshot) {
        final double size = heightSnapshot.data ?? 150.0;

        try {
          if (isUrl) {
            return SizedBox(
              width: size,
              height: size,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  lottieColor,
                  BlendMode.srcATop,
                ),
                child: Lottie.network(
                  path,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  animate: true,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) {
                    AppLogger.error('Lottie network error: $error');
                    return _buildDefaultLoader();
                  },
                ),
              ),
            );
          } else {
            return SizedBox(
              width: size,
              height: size,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  lottieColor,
                  BlendMode.srcATop,
                ),
                child: Lottie.asset(
                  path,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  animate: true,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) {
                    AppLogger.error('Lottie asset error, using default loader: $error');
                    return _buildDefaultLoader();
                  },
                ),
              ),
            );
          }
        } catch (e) {
          AppLogger.error('Lottie loading failed, using default loader: $e');
          return _buildDefaultLoader();
        }
      },
    );
  }

  String _errorTitleText() {
    return _config?.layout.uiTexts.errorLoadingConfig ?? 'Error loading configuration';
  }

  String _retryButtonText() {
    return _config?.layout.uiTexts.retryButton ?? 'Retry';
  }

  @override
  Widget build(BuildContext context) {
    final appTitle = _config != null
        ? '${_config!.personalInfo.name} | ${_config!.personalInfo.title}'
        : 'Loading...';

    if (_isLoading) {
      return MaterialApp(
        title: appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: _getThemeMode(),
        home: Scaffold(
          body: Container(
            color: Colors.transparent,
            child: Center(
              child: _buildLoader(),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return MaterialApp(
        title: appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: _getThemeMode(),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _errorTitleText(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _loadConfig();
                    },
                    child: Text(_retryButtonText()),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final lightTheme = ThemeService.createLightTheme(_config!.theme);
    final darkTheme = ThemeService.createDarkTheme(_config!.theme);

    return MaterialApp(
      title: '${_config!.personalInfo.name} | ${_config!.personalInfo.title}',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _getThemeMode(),
      home: MyWebsiteScreen(
        config: _config!,
        onThemeToggle: _cycleTheme,
        onThemeChanged: _changeTheme,
        themeMode: _themeMode,
        animationController: _animationController,
        onLanguageChanged: _onLanguageChanged,
        isLoadingComplete: !_isLoading,
      ),
    );
  }
}
