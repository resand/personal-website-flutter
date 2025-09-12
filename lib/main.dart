import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
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
  
  // Initialize preferences first
  await PreferencesService.init();
  
  // Language flags are now handled directly in the language selector
  
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
    
    // Load saved theme synchronously (PreferencesService already initialized in main)
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
      
      // Load config without artificial delays
      final loadedConfig = await ConfigService.loadConfig();
      
      AppLogger.success('Config loaded successfully');
      
      // Set config immediately but keep loading until resources are ready
      setState(() {
        _config = loadedConfig;
        
        // Only use config default theme if no theme was saved
        if (PreferencesService.getSavedTheme() == null) {
          _themeMode = _parseThemeModeFromConfig(loadedConfig.theme.defaultMode);
        }
      });
      
      // Wait for critical resources to load
      await _waitForResourcesToLoad(loadedConfig);
      
      // Hide the loader - language selector loads quickly now
      setState(() {
        _isLoading = false;
      });
      
    } catch (e, stackTrace) {
      AppLogger.error('Error loading config: $e');
      AppLogger.error('Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _waitForResourcesToLoad(MyWebsiteConfig config) async {
    AppLogger.info('Waiting for ALL resources to load...');
    
    final List<Future<void>> resourceFutures = [];
    
    // Preload avatar image
    if (config.personalInfo.avatarUrl.isNotEmpty) {
      resourceFutures.add(_preloadImage(config.personalInfo.avatarUrl));
    }
    
    // Preload logo images
    if (config.personalInfo.logoLightUrl != null && config.personalInfo.logoLightUrl!.isNotEmpty) {
      resourceFutures.add(_preloadImage(config.personalInfo.logoLightUrl!));
    }
    if (config.personalInfo.logoDarkUrl != null && config.personalInfo.logoDarkUrl!.isNotEmpty) {
      resourceFutures.add(_preloadImage(config.personalInfo.logoDarkUrl!));
    }
    
    // Preload ALL project images
    for (final project in config.projects) {
      if (project.imageUrl != null && project.imageUrl!.isNotEmpty) {
        resourceFutures.add(_preloadImage(project.imageUrl!));
      }
    }
    
    // Experience and volunteering don't currently have images to preload
    // If needed in the future, add image preloading here
    
    // Preload skills images (if any)
    // Skills typically don't have images, but we're ready for it
    
    // Preload blog images (if any)
    // Blog images come from RSS feeds, we'll handle them separately
    resourceFutures.add(_preloadBlogImages());
    
    // Language flags are now handled directly in the language selector
    
    // Preload any additional images from layout or theme
    _preloadAdditionalImages(config, resourceFutures);
    
    AppLogger.info('Preloading ${resourceFutures.length} resources...');
    
    // Wait for ALL images to load
    if (resourceFutures.isNotEmpty) {
      try {
        await Future.wait(resourceFutures);
        AppLogger.success('All resources loaded successfully');
      } catch (e) {
        AppLogger.warning('Some resources failed to load: $e');
        // Continue anyway - don't block the app
      }
    }
    
    // Additional small delay to ensure DOM is ready
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _preloadImage(String imageUrl) async {
    try {
      if (imageUrl.startsWith('http')) {
        // For network images, we'll use a simple fetch to preload
        await _preloadNetworkImage(imageUrl);
      } else if (imageUrl.startsWith('images/') || imageUrl.startsWith('/images/')) {
        // For web root images (like logos), skip preloading to avoid asset loading attempts
        AppLogger.info('Skipping preload for web root image: $imageUrl');
        return;
      } else {
        // For true local assets, use precacheImage
        await _preloadLocalImage(imageUrl);
      }
    } catch (e) {
      AppLogger.warning('Failed to preload image $imageUrl: $e');
    }
  }

  Future<void> _preloadNetworkImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        AppLogger.info('Successfully preloaded network image: $imageUrl');
      } else {
        AppLogger.warning('Failed to preload network image $imageUrl: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.warning('Error preloading network image $imageUrl: $e');
    }
  }

  Future<void> _preloadLocalImage(String imageUrl) async {
    // For local images, we can use precacheImage
    try {
      await precacheImage(AssetImage(imageUrl), context)
          .timeout(const Duration(seconds: 5));
      AppLogger.info('Successfully precached local image: $imageUrl');
    } catch (e) {
      AppLogger.warning('Failed to precache local image $imageUrl: $e');
    }
  }

  void _preloadAdditionalImages(MyWebsiteConfig config, List<Future<void>> resourceFutures) {
    // Preload any background images or decorative images
    // These would be defined in the theme or layout config if they exist
    
    // Preload any social media icons or external images
    // These are typically handled by the UI framework, but we can preload them if needed
    
    // Add any other images that might be defined in the future
    // This method is ready for expansion when new image fields are added
  }

  Future<void> _preloadBlogImages() async {
    AppLogger.info('Preloading blog images...');
    
    try {
      // Blog images come from RSS feeds and are loaded dynamically
      // We can't preload them here as they're fetched from external sources
      // But we can add a small delay to ensure the blog service is ready
      await Future.delayed(const Duration(milliseconds: 100));
      AppLogger.info('Blog service ready for dynamic image loading');
      
    } catch (e) {
      AppLogger.warning('Failed to prepare blog service: $e');
    }
  }


  Future<void> _onLanguageChanged() async {
    // Reload config to reflect language changes without showing loader
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
    
    // Persist theme selection
    PreferencesService.saveTheme(_themeMode);
    
    // Trigger button animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _changeTheme(ThemeModeType newTheme) {
    setState(() {
      _themeMode = newTheme;
    });
    
    // Persist theme selection
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
    // Always use Lottie loader - hardcoded
    return _buildLottieLoader();
  }

  Widget _buildDefaultLoader() {
    return CircularProgressIndicator(
      strokeWidth: 3,
      valueColor: AlwaysStoppedAnimation<Color>(
        _config?.theme.lightColors.accent != null 
          ? Color(int.parse('FF${_config!.theme.lightColors.accent.replaceAll('#', '')}', radix: 16))
          : const Color(0xFF10B981) // Default accent color
      ),
    );
  }

  Widget _buildLottieLoader() {
    // Determine current theme mode
    final bool isDarkMode = _themeMode == ThemeModeType.dark || 
        (_themeMode == ThemeModeType.auto && 
         WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);

    // Hardcoded local Lottie path - always loader.json
    const String lottiePath = 'assets/lotties/loader.json';
    
    try {
      return _buildLottieWithDynamicColor(lottiePath, isDarkMode, false);
    } catch (e) {
      AppLogger.error('Error building Lottie loader: $e');
      return _buildDefaultLoader();
    }
  }

  Widget _buildLottieWithDynamicColor(String path, bool isDarkMode, bool isUrl) {
    // Choose color based on theme configuration
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
            // For local files, try asset loading with color filter
            AppLogger.info('Loading Lottie asset with dynamic color: $path (${isDarkMode ? "dark" : "light"} mode)');
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


  @override
  Widget build(BuildContext context) {
    // Use config title if available, fallback to generic title
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
          body: Container(
            color: Colors.transparent,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Error al cargar la configuración',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    child: const Text('Reintentar'),
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

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
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
      },
    );
  }
}