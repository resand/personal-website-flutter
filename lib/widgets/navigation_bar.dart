import 'package:flutter/material.dart';
import '../models/website_config.dart';
import '../utils/theme_types.dart';
import 'theme_selector_dropdown.dart';
import 'language_selector.dart';

// Default section order - can be overridden by config
const List<String> _defaultSectionOrder = [
  'hero',
  'about', 
  'experience',
  'skills',
  'projects',
  'volunteering',
  'education',
  'certifications',
  'blog',
  'contact',
];

class MyWebsiteNavigationBar extends StatefulWidget {
  final MyWebsiteConfig config;
  final Function(String) onSectionTap;
  final VoidCallback? onMenuTap;
  final Function(Offset?)? onThemeToggle;
  final Function(ThemeModeType)? onThemeChanged;
  final VoidCallback? onLanguageChanged;
  final ThemeModeType themeMode;
  final AnimationController? animationController;
  final String? currentSection;
  final bool isLoadingComplete;

  const MyWebsiteNavigationBar({
    super.key,
    required this.config,
    required this.onSectionTap,
    this.onMenuTap,
    this.onThemeToggle,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.themeMode = ThemeModeType.auto,
    this.animationController,
    this.currentSection,
    this.isLoadingComplete = true,
  });

  @override
  State<MyWebsiteNavigationBar> createState() => _MyWebsiteNavigationBarState();
}

class _MyWebsiteNavigationBarState extends State<MyWebsiteNavigationBar> with SingleTickerProviderStateMixin {
  late AnimationController _localAnimationController;
  bool _languageSelectorReady = false;

  @override
  void initState() {
    super.initState();
    _localAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _checkLanguageSelectorReady();
  }

  @override
  void dispose() {
    _localAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkLanguageSelectorReady() async {
    // Since flags are pre-loaded in main(), just mark as ready after a short delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      setState(() {
        _languageSelectorReady = true;
      });
      // Language selector is now ready immediately
    }
  }

  Widget _buildLanguageSelector(bool isMobile) {
    return isMobile 
      ? Flexible(
          child: LanguageSelector(
            onLanguageChanged: widget.onLanguageChanged,
            tooltip: widget.config.layout.uiTexts.languageSelectorTooltip,
            config: widget.config,
          ),
        )
      : LanguageSelector(
          onLanguageChanged: widget.onLanguageChanged,
          tooltip: widget.config.layout.uiTexts.languageSelectorTooltip,
          config: widget.config,
        );
  }

  Widget _buildThemeSelector(bool isMobile) {
    return isMobile
      ? Flexible(
          child: ThemeSelectorDropdown(
            themeMode: widget.themeMode,
            onThemeChanged: widget.onThemeChanged!,
            onThemeToggle: widget.onThemeToggle!,
            config: widget.config,
            tooltip: widget.config.layout.uiTexts.themeSelectorTooltip,
          ),
        )
      : ThemeSelectorDropdown(
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged!,
          onThemeToggle: widget.onThemeToggle!,
          config: widget.config,
          tooltip: widget.config.layout.uiTexts.themeSelectorTooltip,
        );
  }


  // Get the configured section order, with fallback to default
  List<String> get _sectionOrder => widget.config.layout.sectionOrder.isNotEmpty 
      ? widget.config.layout.sectionOrder 
      : _defaultSectionOrder;

  // Helper method to check if a section should be shown
  bool _isSectionEnabled(String sectionId) {
    switch (sectionId) {
      case 'hero': return widget.config.layout.showHeroSection;
      case 'about': return widget.config.layout.showAboutSection;
      case 'experience': return widget.config.layout.showExperienceSection;
      case 'skills': return widget.config.layout.showSkillsSection;
      case 'projects': return widget.config.layout.showProjectsSection;
      case 'volunteering': return widget.config.layout.showVolunteeringSection;
      case 'education': return widget.config.layout.showEducationSection;
      case 'certifications': return widget.config.layout.showCertificationsSection;
      case 'blog': return widget.config.layout.showBlogSection;
      case 'contact': return widget.config.layout.showContactSection;
      default: return false;
    }
  }

  // Helper method to get section label
  String _getSectionLabel(String sectionId) {
    switch (sectionId) {
      case 'hero': return widget.config.layout.navigationLabels.home;
      case 'about': return widget.config.layout.navigationLabels.about;
      case 'experience': return widget.config.layout.navigationLabels.experience;
      case 'skills': return widget.config.layout.navigationLabels.skills;
      case 'projects': return widget.config.layout.navigationLabels.projects;
      case 'volunteering': return widget.config.layout.navigationLabels.volunteering;
      case 'education': return widget.config.layout.navigationLabels.education;
      case 'certifications': return widget.config.layout.navigationLabels.certifications;
      case 'blog': return widget.config.layout.navigationLabels.blog;
      case 'contact': return widget.config.layout.navigationLabels.contact;
      default: return '';
    }
  }

  Widget _buildLogoOrName(BuildContext context, bool isMobile) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final logoHeight = widget.config.layout.logoHeight;
    
    // Determine which logo to use
    String? logoUrl;
    if (widget.config.personalInfo.logoLightUrl != null && widget.config.personalInfo.logoDarkUrl != null) {
      // Use theme-specific logo
      logoUrl = isDarkMode 
        ? widget.config.personalInfo.logoDarkUrl 
        : widget.config.personalInfo.logoLightUrl;
    }

    // Show logo or name
    if (logoUrl != null) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: isMobile ? logoHeight * 0.7 : logoHeight,
          maxWidth: 280,
        ),
        child: _buildLogoImage(logoUrl, isMobile, logoHeight),
      );
    } else {
      return _buildNameText(context);
    }
  }

  Widget _buildLogoImage(String logoUrl, bool isMobile, double logoHeight) {
    final isNetworkImage = logoUrl.startsWith('http://') || logoUrl.startsWith('https://');
    final height = isMobile ? logoHeight * 0.7 : logoHeight;
    
    if (isNetworkImage) {
      return Image.network(
        logoUrl,
        height: height,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return SizedBox(
              height: height,
              width: 150,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildNameText(context);
        },
      );
    } else {
      // For web production, treat local paths as web root paths
      final webUrl = logoUrl.startsWith('/') ? logoUrl : '/$logoUrl';
      return Image.network(
        webUrl,
        height: height,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return SizedBox(
              height: height,
              width: 150,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildNameText(context);
        },
      );
    }
  }

  Widget _buildNameText(BuildContext context) {
    return Text(
      widget.config.personalInfo.name.split(' ').first,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 40,  // Same as footer padding
        vertical: isMobile ? 16 : (isTablet ? 20 : 24)
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.onSectionTap('hero'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: _buildLogoOrName(context, isMobile),
            ),
          ),
          Expanded(
            child: isMobile 
              ? widget.onMenuTap != null 
                ? Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: widget.onMenuTap,
                      icon: const Icon(Icons.menu),
                    ),
                  )
                : Align(
                    alignment: Alignment.centerRight,
                    child: _buildMobileNavigation(),
                  )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isTablet)
                      _buildTabletNavigation()
                    else
                      _buildDesktopNavigation(),
                  ],
                ),
          ),
        ],
      ),
    );
  }


  Widget _buildMobileNavigation() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isLoadingComplete && _languageSelectorReady)
          _buildLanguageSelector(true),
        if (widget.isLoadingComplete && _languageSelectorReady && widget.onThemeToggle != null && widget.onThemeChanged != null) 
          const SizedBox(height: 6),
        if (widget.onThemeToggle != null && widget.onThemeChanged != null)
          _buildThemeSelector(true),
      ],
    );
  }


  Widget _buildDesktopNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Build navigation items in configured order
                for (String sectionId in _sectionOrder)
                  if (_isSectionEnabled(sectionId))
                    _buildNavItem(context, _getSectionLabel(sectionId), sectionId),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        if (widget.isLoadingComplete && _languageSelectorReady)
          _buildLanguageSelector(false),
        if (widget.isLoadingComplete && _languageSelectorReady) const SizedBox(width: 3),
        if (widget.onThemeToggle != null && widget.onThemeChanged != null)
          _buildThemeSelector(false),
      ],
    );
  }

  Widget _buildTabletNavigation() {
    // Build navigation items in configured order
    final navItems = <Widget>[];
    for (String sectionId in _sectionOrder) {
      if (_isSectionEnabled(sectionId)) {
        navItems.add(_buildNavItem(context, _getSectionLabel(sectionId), sectionId));
      }
    }

    final firstRowItems = navItems.take((navItems.length / 2).ceil()).toList();
    final secondRowItems = navItems.skip((navItems.length / 2).ceil()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ...firstRowItems,
            const SizedBox(width: 3),
            if (_languageSelectorReady)
              _buildLanguageSelector(true), // Tablet uses mobile-style switches
            const SizedBox(width: 2),
            if (widget.onThemeToggle != null && widget.onThemeChanged != null)
              _buildThemeSelector(true), // Tablet uses mobile-style switches
          ],
        ),
        if (secondRowItems.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: secondRowItems,
          ),
        ],
      ],
    );
  }


  Widget _buildNavItem(BuildContext context, String title, String section) {
    final isActive = widget.currentSection == section;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: _NavItemStateful(
        title: title,
        section: section,
        isActive: isActive,
        onTap: widget.onSectionTap,
        config: widget.config,
      ),
    );
  }
}

class _NavItemStateful extends StatefulWidget {
  final String title;
  final String section;
  final bool isActive;
  final Function(String) onTap;
  final MyWebsiteConfig config;

  const _NavItemStateful({
    required this.title,
    required this.section,
    required this.isActive,
    required this.onTap,
    required this.config,
  });

  @override
  State<_NavItemStateful> createState() => _NavItemStatefulState();
}

class _NavItemStatefulState extends State<_NavItemStateful> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final navConfig = widget.config.layout.navigation;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: navConfig.hoverAnimationDuration),
        constraints: const BoxConstraints(minWidth: 60),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: widget.isActive 
            ? Theme.of(context).colorScheme.primary.withValues(alpha: navConfig.activeBackgroundOpacity)
            : isHovered 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: navConfig.hoverBackgroundOpacity)
              : null,
          border: widget.isActive && navConfig.showActiveBorder
            ? Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
        ),
        child: TextButton(
          onPressed: () => widget.onTap(widget.section),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            overlayColor: Colors.transparent,
          ),
          child: AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: navConfig.hoverAnimationDuration),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500,
              color: widget.isActive 
                ? Theme.of(context).colorScheme.primary
                : isHovered
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 13,
            ) ?? const TextStyle(),
            child: Text(
              widget.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}