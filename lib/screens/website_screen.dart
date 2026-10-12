import 'dart:async';
import 'package:material_ui/material_ui.dart';
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
  final Set<String> _revealedSections = {'hero'};

  Timer? _scrollDebounce;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateRevealedSections());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollDebounce?.isActive ?? false) return;
    _scrollDebounce = Timer(const Duration(milliseconds: 80), _updateCurrentSection);
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Get the configured section order, with fallback to default
  List<String> get _sectionOrder => widget.config.layout.sectionOrder;

  // Mark sections as revealed once their top enters the lower part of the viewport
  void _updateRevealedSections() {
    if (!widget.config.layout.enableAnimations) return;
    final revealLine = MediaQuery.sizeOf(context).height * 0.85;
    var changed = false;
    for (final section in _sectionOrder) {
      if (_revealedSections.contains(section)) continue;
      final box = _sectionKeys[section]?.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.localToGlobal(Offset.zero).dy < revealLine) {
        _revealedSections.add(section);
        changed = true;
      }
    }
    if (changed) setState(() {});
  }

  void _updateCurrentSection() {
    _updateRevealedSections();
    String? newSection;
    final navbarHeight = _getNavbarHeight(context);
    final threshold = navbarHeight + 20; // navbar height + 20px margin

    // Check if we're at the bottom of the page
    final isAtBottom = _scrollController.offset >=
        _scrollController.position.maxScrollExtent - 100;

    // If at bottom, set to last section
    if (isAtBottom && _sectionOrder.isNotEmpty) {
      newSection = _sectionOrder.last;
    } else {
      // Find the current section in viewport
      for (String section in _sectionOrder) {
        final key = _sectionKeys[section];
        if (key?.currentContext != null) {
          final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final position = renderBox.localToGlobal(Offset.zero);
            // If section is in viewport
            if (position.dy <= threshold && position.dy + renderBox.size.height > threshold) {
              newSection = section;
              break;
            }
          }
        }
      }
    }

    // Only update if we found a section and it's different from current
    if (newSection != null && newSection != currentSection) {
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
      case 'hero': return HeroSection(config: widget.config, onViewProjects: () => _scrollToSection('projects'));
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
    final logoHeight = widget.config.layout.logoHeight;

    if (ResponsiveUtils.isMobile(context)) {
      return (logoHeight * 0.7) + 32;
    } else if (ResponsiveUtils.isTablet(context)) {
      return logoHeight + 60;
    } else {
      return logoHeight + 48;
    }
  }

  Future<void> _onLanguageChanged() async {
    if (widget.onLanguageChanged != null) {
      widget.onLanguageChanged!();
    }
  }

  Widget _buildRevealable(String sectionId) {
    final visible = !widget.config.layout.enableAnimations || _revealedSections.contains(sectionId);
    return Container(
      key: _sectionKeys[sectionId],
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 0.04),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          child: _buildSectionWidget(sectionId)!,
        ),
      ),
    );
  }

  Widget _buildBackToTop() {
    final show = currentSection != null && currentSection != 'hero';
    return Positioned(
      right: 16,
      bottom: 16,
      child: AnimatedScale(
        scale: show ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton.small(
          heroTag: 'back_to_top',
          tooltip: widget.config.layout.navigationLabels.home,
          onPressed: () => _scrollToSection('hero'),
          child: const Icon(Icons.keyboard_arrow_up),
        ),
      ),
    );
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
                    _buildRevealable(sectionId),
                MyWebsiteFooter(
                  config: widget.config,
                  onSectionTap: _scrollToSection,
                ),
              ],
            ),
          ),
          _buildBackToTop(),
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
    final sections = _sectionOrder.where(_isSectionEnabled).toList();
    // First 4 sections get a tab; the rest go to the "More" bottom sheet
    final mainSections = sections.take(4).toList();
    final moreSections = sections.skip(4).toList();
    final hasMore = moreSections.isNotEmpty;

    var selectedIndex = mainSections.indexWhere((id) => id == currentSection);
    if (selectedIndex < 0) {
      selectedIndex = hasMore && moreSections.contains(currentSection) ? mainSections.length : 0;
    }

    return NavigationBar(
      height: 64,
      selectedIndex: selectedIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (index) {
        if (index < mainSections.length) {
          _scrollToSection(mainSections[index]);
        } else {
          _showMoreSheet(moreSections);
        }
      },
      destinations: [
        for (final id in mainSections)
          NavigationDestination(
            icon: Icon(_getSectionIcon(id)),
            label: _getSectionLabel(id),
          ),
        if (hasMore)
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            label: widget.config.layout.uiTexts.moreMenu,
          ),
      ],
    );
  }

  void _showMoreSheet(List<String> sections) {
    showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final id in sections)
              ListTile(
                leading: Icon(_getSectionIcon(id)),
                title: Text(_getSectionLabel(id)),
                selected: currentSection == id,
                trailing: currentSection == id ? const Icon(Icons.check_circle, size: 18) : null,
                onTap: () => Navigator.of(sheetContext).pop(id),
              ),
          ],
        ),
      ),
    ).then((id) {
      if (id != null) _scrollToSection(id);
    });
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
          for (final sectionId in _sectionOrder)
            if (_isSectionEnabled(sectionId)) _buildDrawerItem(_getSectionLabel(sectionId), sectionId),
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