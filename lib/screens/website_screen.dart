import 'package:flutter/material.dart';
import '../models/website_config.dart';
import '../utils/responsive_utils.dart';
import '../utils/theme_types.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/about_section.dart';
import '../widgets/experience_section.dart';
import '../widgets/skills_section.dart';
import '../widgets/projects_section.dart';
import '../widgets/volunteering_section.dart';
import '../widgets/education_section.dart';
import '../widgets/certifications_section.dart';
import '../widgets/blog_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/footer.dart';
import '../services/localization_service.dart';


class MyWebsiteScreen extends StatefulWidget {
  final MyWebsiteConfig config;
  final Function(Offset?) onThemeToggle;
  final Function(ThemeModeType) onThemeChanged;
  final ThemeModeType themeMode;
  final AnimationController animationController;
  final VoidCallback? onLanguageChanged;
  final bool isLoadingComplete;
  
  const MyWebsiteScreen({
    super.key, 
    required this.config,
    required this.onThemeToggle,
    required this.onThemeChanged,
    required this.themeMode,
    required this.animationController,
    this.onLanguageChanged,
    this.isLoadingComplete = true,
  });

  @override
  State<MyWebsiteScreen> createState() => _MyWebsiteScreenState();
}

class _MyWebsiteScreenState extends State<MyWebsiteScreen> with TickerProviderStateMixin {
  String? currentSection = 'hero';
  

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final Map<String, GlobalKey> _sectionKeys = {
    'hero': GlobalKey(debugLabel: 'hero'),
    'about': GlobalKey(debugLabel: 'about'),
    'experience': GlobalKey(debugLabel: 'experience'),
    'skills': GlobalKey(debugLabel: 'skills'),
    'projects': GlobalKey(debugLabel: 'projects'),
    'volunteering': GlobalKey(debugLabel: 'volunteering'),
    'education': GlobalKey(debugLabel: 'education'),
    'certifications': GlobalKey(debugLabel: 'certifications'),
    'blog': GlobalKey(debugLabel: 'blog'),
    'contact': GlobalKey(debugLabel: 'contact'),
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateCurrentSection);
  }
  
  
  @override
  void dispose() {
    _scrollController.removeListener(_updateCurrentSection);
    _scrollController.dispose();
    super.dispose();
  }

  // Get the configured section order, with fallback to default
  List<String> get _sectionOrder => widget.config.layout.sectionOrder;

  void _updateCurrentSection() {
    String newSection = 'hero';
    final navbarHeight = _getNavbarHeight(context);

    for (String section in _sectionOrder) {
      final key = _sectionKeys[section];
      if (key?.currentContext != null) {
        final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          // If section is in viewport (accounting for navbar height + small margin)
          final threshold = navbarHeight + 20; // navbar height + 20px margin
          if (position.dy <= threshold && position.dy + renderBox.size.height > threshold) {
            newSection = section;
            break;
          }
        }
      }
    }

    if (newSection != currentSection) {
      setState(() {
        currentSection = newSection;
      });
    }
  }

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

  // Helper method to build section widget
  Widget? _buildSectionWidget(String sectionId) {
    switch (sectionId) {
      case 'hero': return HeroSection(config: widget.config);
      case 'about': return AboutSection(config: widget.config);
      case 'experience': return ExperienceSection(config: widget.config);
      case 'skills': return SkillsSection(config: widget.config);
      case 'projects': return ProjectsSection(config: widget.config);
      case 'volunteering': return VolunteeringSection(config: widget.config);
      case 'education': return EducationSection(config: widget.config);
      case 'certifications': return CertificationsSection(config: widget.config);
      case 'blog': return BlogSection(config: widget.config);
      case 'contact': return ContactSection(config: widget.config);
      default: return null;
    }
  }

  // Helper method to get section icon for mobile navigation
  IconData _getSectionIcon(String sectionId) {
    switch (sectionId) {
      case 'hero': return Icons.home;
      case 'about': return Icons.person;
      case 'experience': return Icons.work;
      case 'skills': return Icons.build;
      case 'projects': return Icons.code;
      case 'volunteering': return Icons.volunteer_activism;
      case 'education': return Icons.school;
      case 'certifications': return Icons.verified;
      case 'blog': return Icons.article;
      case 'contact': return Icons.contact_mail;
      default: return Icons.circle;
    }
  }

  // Helper method to get section label for mobile navigation
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


  double _getNavbarHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final logoHeight = widget.config.layout.logoHeight;
    
    if (isMobile) {
      return (logoHeight * 0.7) + 32; // Mobile: reduced logo + 16px padding * 2
    } else if (isTablet) {
      return logoHeight + 60; // Tablet: logo height + extra space for two-row layout
    } else {
      return logoHeight + 48; // Desktop: logo height + 24px padding * 2
    }
  }

  Future<void> _onLanguageChanged() async {
    if (widget.onLanguageChanged != null) {
      widget.onLanguageChanged!();
    }
  }

  void _scrollToSection(String section) {
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
    
    final key = _sectionKeys[section];
    if (key?.currentContext != null) {
      try {
        final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          final navbarHeight = _getNavbarHeight(context);
          
          // Calculate target scroll position with navbar offset compensation
          final targetScrollPosition = _scrollController.offset + position.dy - navbarHeight;
          
          _scrollController.animateTo(
            targetScrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      } catch (e) {
        // Fallback to ensureVisible if calculation fails
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildDrawer() : null,
      bottomNavigationBar: isMobile ? _buildBottomNavigationBar() : null,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(bottom: isMobile ? 80 : 0), // Space for tab bar
            child: Column(
              children: [
                SizedBox(height: _getNavbarHeight(context)), // Space for fixed navbar
                // Build sections in configured order
                for (String sectionId in _sectionOrder)
                  if (_isSectionEnabled(sectionId))
                    Container(
                      key: _sectionKeys[sectionId],
                      child: _buildSectionWidget(sectionId)!,
                    ),
                MyWebsiteFooter(
                  config: widget.config,
                  onSectionTap: _scrollToSection,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _getNavbarHeight(context),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: MyWebsiteNavigationBar(
                config: widget.config,
                onSectionTap: _scrollToSection,
                onMenuTap: null,
                onThemeToggle: widget.onThemeToggle,
                onThemeChanged: widget.onThemeChanged,
                onLanguageChanged: _onLanguageChanged,
                currentSection: currentSection,
                themeMode: widget.themeMode,
                animationController: widget.animationController,
                isLoadingComplete: widget.isLoadingComplete,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    // Get all enabled sections in configured order
    final allEnabledSections = _sectionOrder
        .where((sectionId) => _isSectionEnabled(sectionId))
        .toList();
    
    // Decide which sections go in main tabs vs "More" menu
    // Main tabs: first 4 sections (fits well on most screens)
    final mainTabSections = allEnabledSections.take(4).toList();
    final moreSections = allEnabledSections.skip(4).toList();
    
    final allTabs = <Widget>[];
    
    // Add main tabs in configured order
    for (String sectionId in mainTabSections) {
      final isActive = currentSection == sectionId;
      allTabs.add(
        Expanded(
          child: _buildTabItem(
            icon: _getSectionIcon(sectionId),
            label: _getSectionLabel(sectionId),
            isActive: isActive,
            onTap: () => _scrollToSection(sectionId),
          ),
        ),
      );
    }
    
    // Add "More" button if there are secondary sections
    if (moreSections.isNotEmpty) {
      final hasActiveMoreSection = moreSections.contains(currentSection);
      allTabs.add(
        Expanded(
          child: _buildMoreTabItem(
            moreSections: moreSections,
            isActive: hasActiveMoreSection,
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: allTabs,
          ),
        ),
      ),
    );
  }
  
  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isActive ? 1 : 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated top indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: 3,
              width: isActive ? 24 : 0,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ] : null,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.all(isActive ? 2 : 0),
                decoration: BoxDecoration(
                  color: isActive 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isActive 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: isActive ? 11 : 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreTabItem({
    required List<String> moreSections,
    required bool isActive,
  }) {
    return PopupMenuButton<String>(
      tooltip: widget.config.layout.uiTexts.moreMenu,
      onSelected: (String section) => _scrollToSection(section),
      itemBuilder: (BuildContext context) => moreSections.map((sectionId) {
        final itemIsActive = currentSection == sectionId;
        return PopupMenuItem<String>(
          value: sectionId,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: itemIsActive
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: itemIsActive
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _getSectionIcon(sectionId),
                    color: itemIsActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getSectionLabel(sectionId),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: itemIsActive ? FontWeight.w600 : FontWeight.w500,
                      color: itemIsActive
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                if (itemIsActive) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
      offset: const Offset(0, -220),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isActive ? 1 : 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated top indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: 3,
              width: isActive ? 24 : 0,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ] : null,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.all(isActive ? 2 : 0),
                decoration: BoxDecoration(
                  color: isActive 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: isActive 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: isActive ? 11 : 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              child: Text(
                widget.config.layout.uiTexts.moreMenu,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: widget.config.personalInfo.avatarUrl.startsWith('http')
                      ? NetworkImage(widget.config.personalInfo.avatarUrl)
                      : AssetImage(widget.config.personalInfo.avatarUrl) as ImageProvider,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.config.personalInfo.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.config.personalInfo.title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(widget.config.layout.navigationLabels.home, 'hero'),
          if (widget.config.layout.showAboutSection) _buildDrawerItem(widget.config.layout.navigationLabels.about, 'about'),
          if (widget.config.layout.showExperienceSection) _buildDrawerItem(widget.config.layout.navigationLabels.experience, 'experience'),
          if (widget.config.layout.showSkillsSection) _buildDrawerItem(widget.config.layout.navigationLabels.skills, 'skills'),
          if (widget.config.layout.showProjectsSection) _buildDrawerItem(widget.config.layout.navigationLabels.projects, 'projects'),
          if (widget.config.layout.showVolunteeringSection) _buildDrawerItem(widget.config.layout.navigationLabels.volunteering, 'volunteering'),
          if (widget.config.layout.showBlogSection) _buildDrawerItem(widget.config.layout.navigationLabels.blog, 'blog'),
          if (widget.config.layout.showContactSection) _buildDrawerItem(widget.config.layout.navigationLabels.contact, 'contact'),
          const Divider(),
          FutureBuilder<String>(
            future: LocalizationService.currentLocale,
            builder: (context, currentLocaleSnapshot) {
              final currentLocale = currentLocaleSnapshot.data ?? '';
              return ListTile(
                leading: FutureBuilder<String>(
                  future: LocalizationService.getLanguageCode(currentLocale),
                  builder: (context, snapshot) {
                    final code = snapshot.data ?? currentLocale.toUpperCase();
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        code,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
                title: FutureBuilder<String>(
                  future: LocalizationService.getLanguageName(currentLocale),
                  builder: (context, snapshot) => Text(snapshot.data ?? currentLocale.toUpperCase()),
                ),
                subtitle: Text(widget.config.layout.uiTexts.changeLanguage),
                trailing: PopupMenuButton<String>(
                      onSelected: (String locale) async {
                        Navigator.pop(context);
                        await LocalizationService.setLocale(locale);
                        await _onLanguageChanged();
                      },
                      itemBuilder: (BuildContext context) => LocalizationService.supportedLocales.map((locale) => 
                        PopupMenuItem<String>(
                          value: locale,
                          child: Row(
                            children: [
                              FutureBuilder<String>(
                                future: LocalizationService.getLanguageCode(locale),
                                builder: (context, snapshot) {
                                  final code = snapshot.data ?? locale.toUpperCase();
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      code,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              FutureBuilder<String>(
                                future: LocalizationService.getLanguageName(locale),
                                builder: (context, snapshot) => Text(snapshot.data ?? locale.toUpperCase()),
                              ),
                              if (locale == currentLocale) ...[
                                const Spacer(),
                                const Icon(Icons.check, size: 16),
                              ],
                            ],
                          ),
                        )
                      ).toList(),
                      child: const Icon(Icons.arrow_drop_down),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(_getDrawerThemeIcon(widget.themeMode)),
            title: Text(_getDrawerThemeText(widget.themeMode)),
            subtitle: Text(widget.config.layout.uiTexts.changeTheme),
            onTap: () {
              Navigator.pop(context);
              widget.onThemeToggle(null);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, String section) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        _scrollToSection(section);
      },
    );
  }

  IconData _getDrawerThemeIcon(ThemeModeType themeMode) {
    switch (themeMode) {
      case ThemeModeType.auto:
        return Icons.brightness_auto;
      case ThemeModeType.light:
        return Icons.light_mode;
      case ThemeModeType.dark:
        return Icons.dark_mode;
    }
  }

  String _getDrawerThemeText(ThemeModeType themeMode) {
    switch (themeMode) {
      case ThemeModeType.auto:
        return widget.config.layout.uiTexts.themeAutoDrawer;
      case ThemeModeType.light:
        return widget.config.layout.uiTexts.themeLightDrawer;
      case ThemeModeType.dark:
        return widget.config.layout.uiTexts.themeDarkDrawer;
    }
  }
}