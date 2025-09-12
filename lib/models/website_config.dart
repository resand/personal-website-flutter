class MyWebsiteConfig {
  final PersonalInfo personalInfo;
  final LanguageInfo languageInfo;
  final SocialLinks socialLinks;
  final BlogConfig blogConfig;
  final List<Experience> experience;
  final Skills skills;
  final List<Volunteering> volunteering;
  final List<Project> projects;
  final List<Education>? education;
  final List<String>? certifications;
  final ThemeConfig theme;
  final LayoutConfig layout;
  final FooterConfig footer;
  final MetaConfig meta;

  MyWebsiteConfig({
    required this.personalInfo,
    required this.languageInfo,
    required this.socialLinks,
    required this.blogConfig,
    required this.experience,
    required this.skills,
    required this.volunteering,
    required this.projects,
    this.education,
    this.certifications,
    required this.theme,
    required this.layout,
    required this.footer,
    required this.meta,
  });
  
  // Maintain compatibility with existing code
  MediumConfig get mediumConfig => blogConfig.mediumConfig;

  factory MyWebsiteConfig.fromJson(Map<String, dynamic> json) {
    return MyWebsiteConfig(
      personalInfo: PersonalInfo.fromJson(json['personal_info']),
      languageInfo: LanguageInfo.fromJson(json['language_info']),
      socialLinks: SocialLinks.fromJson(json['social_links']),
      blogConfig: json.containsKey('blog_config') 
          ? BlogConfig.fromJson(json['blog_config'])
          : BlogConfig.fromJson({
              'show_latest_posts': json['medium_config']['show_latest_posts'], 
              'max_posts_to_show': json['medium_config']['max_posts_to_show'], 
              'sources': [{'name': 'Medium', 'username': json['medium_config']['username'], 'rss_url': json['medium_config']['rss_url'], 'enabled': true}],
              'section_title': 'Últimas Publicaciones',
              'section_description': 'Mis últimos artículos en Medium',
              'error_title': 'No se pudieron cargar los artículos',
              'error_message': 'Pero puedes visitar mi perfil de Medium directamente',
              'empty_message': 'No hay artículos disponibles',
              'view_all_text': 'Ver todos los artículos en Medium'
            }),
      experience: (json['experience'] as List)
          .map((e) => Experience.fromJson(e))
          .toList(),
      skills: Skills.fromJson(json['skills']),
      volunteering: (json['volunteering'] as List)
          .map((v) => Volunteering.fromJson(v))
          .toList(),
      projects: (json['projects'] as List)
          .map((p) => Project.fromJson(p))
          .toList(),
      education: json['education'] != null 
          ? (json['education'] as List)
              .map((e) => Education.fromJson(e))
              .toList()
          : null,
      certifications: json['certifications'] != null 
          ? List<String>.from(json['certifications'])
          : null,
      theme: ThemeConfig.fromJson(json['theme']),
      layout: LayoutConfig.fromJson(json['layout']),
      footer: FooterConfig.fromJson(json['footer']),
      meta: MetaConfig.fromJson(json['meta']),
    );
  }
}

class PersonalInfo {
  final String name;
  final String title;
  final String subtitle;
  final String bio;
  final String? shortBio;
  final String? funFact;
  final String email;
  final String location;
  final String avatarUrl;
  final String? logoLightUrl;
  final String? logoDarkUrl;
  final String yearsOfExperience;

  PersonalInfo({
    required this.name,
    required this.title,
    required this.subtitle,
    required this.bio,
    this.shortBio,
    this.funFact,
    required this.email,
    required this.location,
    required this.avatarUrl,
    this.logoLightUrl,
    this.logoDarkUrl,
    required this.yearsOfExperience,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      name: json['name'],
      title: json['title'],
      subtitle: json['subtitle'],
      bio: json['bio'],
      shortBio: json['short_bio'],
      funFact: json['fun_fact'],
      email: json['email'],
      location: json['location'],
      avatarUrl: json['avatar_url'],
      logoLightUrl: json['logo_light_url'],
      logoDarkUrl: json['logo_dark_url'],
      yearsOfExperience: json['years_of_experience'],
    );
  }
}

class SocialLink {
  final String platform;
  final String url;

  SocialLink({
    required this.platform,
    required this.url,
  });

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      platform: json['platform'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class SocialLinks {
  final List<SocialLink> links;

  SocialLinks({required this.links});

  factory SocialLinks.fromJson(dynamic json) {
    if (json is List) {
      return SocialLinks(
        links: (json).map((link) => SocialLink.fromJson(link)).toList(),
      );
    } else if (json is Map<String, dynamic>) {
      // Backward compatibility with old object format
      final links = <SocialLink>[];
      json.forEach((platform, url) {
        if (url != null && url.toString().isNotEmpty) {
          links.add(SocialLink(platform: platform, url: url.toString()));
        }
      });
      return SocialLinks(links: links);
    }
    return SocialLinks(links: []);
  }

  // Helper methods for backward compatibility
  String? get linkedin => _getUrlForPlatform('linkedin');
  String? get github => _getUrlForPlatform('github');
  String? get x => _getUrlForPlatform('x');
  String? get medium => _getUrlForPlatform('medium');
  String? get instagram => _getUrlForPlatform('instagram');

  String? _getUrlForPlatform(String platform) {
    try {
      return links.firstWhere((link) => link.platform.toLowerCase() == platform.toLowerCase()).url;
    } catch (e) {
      return null;
    }
  }
}

class BlogSource {
  final String name;
  final String username;
  final String rssUrl;
  final bool enabled;

  BlogSource({
    required this.name,
    required this.username,
    required this.rssUrl,
    required this.enabled,
  });

  factory BlogSource.fromJson(Map<String, dynamic> json) {
    return BlogSource(
      name: json['name'],
      username: json['username'],
      rssUrl: json['rss_url'],
      enabled: json['enabled'],
    );
  }
}

class BlogConfig {
  final bool showLatestPosts;
  final int maxPostsToShow;
  final List<BlogSource> sources;
  final String sectionTitle;
  final String sectionDescription;
  final String errorTitle;
  final String errorMessage;
  final String emptyMessage;
  final String viewAllText;

  BlogConfig({
    required this.showLatestPosts,
    required this.maxPostsToShow,
    required this.sources,
    required this.sectionTitle,
    required this.sectionDescription,
    required this.errorTitle,
    required this.errorMessage,
    required this.emptyMessage,
    required this.viewAllText,
  });

  factory BlogConfig.fromJson(Map<String, dynamic> json) {
    return BlogConfig(
      showLatestPosts: json['show_latest_posts'],
      maxPostsToShow: json['max_posts_to_show'],
      sources: (json['sources'] as List)
          .map((source) => BlogSource.fromJson(source))
          .toList(),
      sectionTitle: json['section_title'] ?? 'Últimas Publicaciones',
      sectionDescription: json['section_description'] ?? 'Mis últimos artículos',
      errorTitle: json['error_title'] ?? 'No se pudieron cargar los artículos',
      errorMessage: json['error_message'] ?? 'Pero puedes visitar mi perfil directamente',
      emptyMessage: json['empty_message'] ?? 'No hay artículos disponibles',
      viewAllText: json['view_all_text'] ?? 'Ver todos los artículos',
    );
  }
  
  // Maintain compatibility with existing code
  MediumConfig get mediumConfig {
    final mediumSource = sources.firstWhere(
      (source) => source.name.toLowerCase() == 'medium',
      orElse: () => sources.first,
    );
    return MediumConfig(
      username: mediumSource.username,
      rssUrl: mediumSource.rssUrl,
      showLatestPosts: showLatestPosts,
      maxPostsToShow: maxPostsToShow,
    );
  }
}

class MediumConfig {
  final String username;
  final String rssUrl;
  final bool showLatestPosts;
  final int maxPostsToShow;

  MediumConfig({
    required this.username,
    required this.rssUrl,
    required this.showLatestPosts,
    required this.maxPostsToShow,
  });
}

class Experience {
  final String company;
  final String position;
  final String duration;
  final String location;
  final String description;
  final List<String> technologies;
  final List<String> highlights;

  Experience({
    required this.company,
    required this.position,
    required this.duration,
    required this.location,
    required this.description,
    required this.technologies,
    required this.highlights,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      company: json['company'],
      position: json['position'],
      duration: json['duration'],
      location: json['location'],
      description: json['description'],
      technologies: List<String>.from(json['technologies']),
      highlights: List<String>.from(json['highlights']),
    );
  }
}

class Skills {
  final List<SkillCategory> categories;

  Skills({
    required this.categories,
  });

  factory Skills.fromJson(Map<String, dynamic> json) {
    return Skills(
      categories: (json['categories'] as List).map((c) => SkillCategory.fromJson(c)).toList(),
    );
  }
}

class SkillCategory {
  final String id;
  final String title;
  final String icon;
  final List<Skill> skills;

  SkillCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.skills,
  });

  factory SkillCategory.fromJson(Map<String, dynamic> json) {
    return SkillCategory(
      id: json['id'],
      title: json['title'],
      icon: json['icon'],
      skills: (json['skills'] as List).map((s) => Skill.fromJson(s)).toList(),
    );
  }
}

class Skill {
  final String name;
  final String level;

  Skill({
    required this.name,
    required this.level,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['name'],
      level: json['level'],
    );
  }
}

class Volunteering {
  final String organization;
  final String role;
  final String duration;
  final String description;
  final String impact;
  final String? website;

  Volunteering({
    required this.organization,
    required this.role,
    required this.duration,
    required this.description,
    required this.impact,
    this.website,
  });

  factory Volunteering.fromJson(Map<String, dynamic> json) {
    return Volunteering(
      organization: json['organization'],
      role: json['role'],
      duration: json['duration'],
      description: json['description'],
      impact: json['impact'],
      website: json['website'],
    );
  }
}

class Project {
  final String name;
  final String description;
  final List<String> technologies;
  final String? githubUrl;
  final String? liveUrl;
  final String? imageUrl;

  Project({
    required this.name,
    required this.description,
    required this.technologies,
    this.githubUrl,
    this.liveUrl,
    this.imageUrl,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['name'],
      description: json['description'],
      technologies: List<String>.from(json['technologies']),
      githubUrl: json['github_url'],
      liveUrl: json['live_url'],
      imageUrl: json['image_url'],
    );
  }
}


class ThemeConfig {
  final String defaultMode;
  final ColorSchemeConfig lightColors;
  final ColorSchemeConfig darkColors;
  final String fontFamily;
  final bool enableAnimations;
  final ElevationConfig elevation;

  ThemeConfig({
    required this.defaultMode,
    required this.lightColors,
    required this.darkColors,
    required this.fontFamily,
    required this.enableAnimations,
    required this.elevation,
  });

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      defaultMode: json['default_mode'] ?? 'auto',
      lightColors: ColorSchemeConfig.fromJson(json['light_colors']),
      darkColors: ColorSchemeConfig.fromJson(json['dark_colors']),
      fontFamily: json['font_family'],
      enableAnimations: json['enable_animations'],
      elevation: ElevationConfig.fromJson(json['elevation']),
    );
  }
}

class ColorSchemeConfig {
  final String primary;
  final String secondary;
  final String accent;
  final String background;
  final String surface;
  final String onPrimary;
  final String onSecondary;
  final String onBackground;
  final String onSurface;
  final String error;
  final String onError;

  ColorSchemeConfig({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onSurface,
    required this.error,
    required this.onError,
  });

  factory ColorSchemeConfig.fromJson(Map<String, dynamic> json) {
    return ColorSchemeConfig(
      primary: json['primary'],
      secondary: json['secondary'],
      accent: json['accent'],
      background: json['background'],
      surface: json['surface'],
      onPrimary: json['on_primary'],
      onSecondary: json['on_secondary'],
      onBackground: json['on_background'],
      onSurface: json['on_surface'],
      error: json['error'],
      onError: json['on_error'],
    );
  }
}

class LayoutConfig {
  final bool showHeroSection;
  final bool showAboutSection;
  final bool showExperienceSection;
  final bool showSkillsSection;
  final bool showProjectsSection;
  final bool showVolunteeringSection;
  final bool showEducationSection;
  final bool showCertificationsSection;
  final bool showBlogSection;
  final bool showContactSection;
  final bool enableDarkMode;
  final bool enableAnimations;
  final double logoHeight;
  final NavigationConfig navigation;
  final List<String> sectionOrder;
  final NavigationLabels navigationLabels;
  final SectionTitles sectionTitles;
  final HeroTexts heroTexts;
  final UITexts uiTexts;
  final ContactTexts contactTexts;
  final AboutTexts aboutTexts;

  LayoutConfig({
    required this.showHeroSection,
    required this.showAboutSection,
    required this.showExperienceSection,
    required this.showSkillsSection,
    required this.showProjectsSection,
    required this.showVolunteeringSection,
    required this.showEducationSection,
    required this.showCertificationsSection,
    required this.showBlogSection,
    required this.showContactSection,
    required this.enableDarkMode,
    required this.enableAnimations,
    required this.logoHeight,
    required this.navigation,
    required this.sectionOrder,
    required this.navigationLabels,
    required this.sectionTitles,
    required this.heroTexts,
    required this.uiTexts,
    required this.contactTexts,
    required this.aboutTexts,
  });

  factory LayoutConfig.fromJson(Map<String, dynamic> json) {
    return LayoutConfig(
      showHeroSection: json['show_hero_section'],
      showAboutSection: json['show_about_section'],
      showExperienceSection: json['show_experience_section'],
      showSkillsSection: json['show_skills_section'],
      showProjectsSection: json['show_projects_section'],
      showVolunteeringSection: json['show_volunteering_section'],
      showEducationSection: json['show_education_section'] ?? true,
      showCertificationsSection: json['show_certifications_section'] ?? true,
      showBlogSection: json['show_blog_section'],
      showContactSection: json['show_contact_section'],
      enableDarkMode: json['enable_dark_mode'],
      enableAnimations: json['enable_animations'],
      logoHeight: (json['logo_height'] ?? 40).toDouble(),
      navigation: NavigationConfig.fromJson(json['navigation'] ?? {}),
      sectionOrder: List<String>.from(json['section_order'] ?? [
        'hero', 'about', 'experience', 'skills', 
        'projects', 'volunteering', 'blog', 'contact'
      ]),
      navigationLabels: NavigationLabels.fromJson(json['navigation_labels']),
      sectionTitles: SectionTitles.fromJson(json['section_titles']),
      heroTexts: HeroTexts.fromJson(json['hero_texts']),
      uiTexts: UITexts.fromJson(json['ui_texts']),
      contactTexts: ContactTexts.fromJson(json['contact_texts']),
      aboutTexts: AboutTexts.fromJson(json['about_texts']),
    );
  }
}

class NavigationLabels {
  final String home;
  final String about;
  final String experience;
  final String skills;
  final String projects;
  final String volunteering;
  final String education;
  final String certifications;
  final String blog;
  final String contact;

  NavigationLabels({
    required this.home,
    required this.about,
    required this.experience,
    required this.skills,
    required this.projects,
    required this.volunteering,
    required this.education,
    required this.certifications,
    required this.blog,
    required this.contact,
  });

  factory NavigationLabels.fromJson(Map<String, dynamic> json) {
    return NavigationLabels(
      home: json['home'] ?? 'Inicio',
      about: json['about'] ?? 'Acerca de',
      experience: json['experience'] ?? 'Experiencia',
      skills: json['skills'] ?? 'Habilidades',
      projects: json['projects'] ?? 'Proyectos',
      volunteering: json['volunteering'] ?? 'Voluntariado',
      education: json['education'] ?? 'Educación',
      certifications: json['certifications'] ?? 'Certificaciones',
      blog: json['blog'] ?? 'Blog',
      contact: json['contact'] ?? 'Contacto',
    );
  }
}

class SectionTitles {
  final String about;
  final String experience;
  final String skills;
  final String projects;
  final String volunteering;
  final String education;
  final String certifications;
  final String blog;
  final String contact;
  final String otherProjects;
  final String yearsExperience;
  final String descriptionText;

  SectionTitles({
    required this.about,
    required this.experience,
    required this.skills,
    required this.projects,
    required this.volunteering,
    required this.education,
    required this.certifications,
    required this.blog,
    required this.contact,
    required this.otherProjects,
    required this.yearsExperience,
    required this.descriptionText,
  });

  factory SectionTitles.fromJson(Map<String, dynamic> json) {
    return SectionTitles(
      about: json['about'] ?? 'Acerca de mí',
      experience: json['experience'] ?? 'Experiencia Profesional',
      skills: json['skills'] ?? 'Habilidades Técnicas',
      projects: json['projects'] ?? 'Proyectos Destacados',
      volunteering: json['volunteering'] ?? 'Voluntariado y Contribuciones',
      education: json['education'] ?? 'Educación',
      certifications: json['certifications'] ?? 'Certificaciones',
      blog: json['blog'] ?? 'Últimas Publicaciones',
      contact: json['contact'] ?? 'Contacto',
      otherProjects: json['other_projects'] ?? 'Otros Proyectos',
      yearsExperience: json['years_experience'] ?? 'Años de Experiencia',
      descriptionText: json['description_text'] ?? 'Especializado en desarrollo web full-stack con experiencia en múltiples tecnologías y frameworks modernos.',
    );
  }
}

class HeroTexts {
  final String greeting;
  final String contactButton;

  HeroTexts({
    required this.greeting,
    required this.contactButton,
  });

  factory HeroTexts.fromJson(Map<String, dynamic> json) {
    return HeroTexts(
      greeting: json['greeting'] ?? 'Hola, soy',
      contactButton: json['contact_button'] ?? 'Contactar',
    );
  }
}


class SocialLabels {
  final String linkedin;
  final String github;
  final String x;
  final String medium;
  final String instagram;

  SocialLabels({
    required this.linkedin,
    required this.github,
    required this.x,
    required this.medium,
    required this.instagram,
  });

  factory SocialLabels.fromJson(Map<String, dynamic> json) {
    return SocialLabels(
      linkedin: json['linkedin'] ?? 'LinkedIn',
      github: json['github'] ?? 'GitHub',
      x: json['x'] ?? 'X',
      medium: json['medium'] ?? 'Medium',
      instagram: json['instagram'] ?? 'Instagram',
    );
  }
}

class UITexts {
  final String languageSelectorTooltip;
  final String themeSelectorTooltip;
  final String moreMenu;
  final String featuredBadge;
  final String codeButton;
  final String viewButton;
  final String minReadText;
  final String themeAuto;
  final String themeLight;
  final String themeDark;
  final String themeAutoDrawer;
  final String themeLightDrawer;
  final String themeDarkDrawer;
  final String configErrorTitle;
  final String errorLoadingConfig;
  final String unknownError;
  final String changeLanguage;
  final String changeTheme;
  final String highlightsTitle;
  final String impactLabel;
  final String viewOrganization;
  final String linkedinButton;
  final List<String> monthNames;
  final SocialLabels socialLabels;

  UITexts({
    required this.languageSelectorTooltip,
    required this.themeSelectorTooltip,
    required this.moreMenu,
    required this.featuredBadge,
    required this.codeButton,
    required this.viewButton,
    required this.minReadText,
    required this.themeAuto,
    required this.themeLight,
    required this.themeDark,
    required this.themeAutoDrawer,
    required this.themeLightDrawer,
    required this.themeDarkDrawer,
    required this.configErrorTitle,
    required this.errorLoadingConfig,
    required this.unknownError,
    required this.changeLanguage,
    required this.changeTheme,
    required this.highlightsTitle,
    required this.impactLabel,
    required this.viewOrganization,
    required this.linkedinButton,
    required this.monthNames,
    required this.socialLabels,
  });

  factory UITexts.fromJson(Map<String, dynamic> json) {
    return UITexts(
      languageSelectorTooltip: json['language_selector_tooltip'] ?? 'Change language',
      themeSelectorTooltip: json['theme_selector_tooltip'] ?? 'Change theme',
      moreMenu: json['more_menu'] ?? 'More',
      featuredBadge: json['featured_badge'] ?? 'Featured',
      codeButton: json['code_button'] ?? 'Code',
      viewButton: json['view_button'] ?? 'View',
      minReadText: json['min_read_text'] ?? 'min read',
      themeAuto: json['theme_auto'] ?? 'Auto',
      themeLight: json['theme_light'] ?? 'Light',
      themeDark: json['theme_dark'] ?? 'Dark',
      themeAutoDrawer: json['theme_auto_drawer'] ?? 'Auto (System)',
      themeLightDrawer: json['theme_light_drawer'] ?? 'Light Mode',
      themeDarkDrawer: json['theme_dark_drawer'] ?? 'Dark Mode',
      configErrorTitle: json['config_error_title'] ?? 'Error loading configuration',
      errorLoadingConfig: json['error_loading_config'] ?? 'Error cargando configuración',
      unknownError: json['unknown_error'] ?? 'Error desconocido',
      changeLanguage: json['change_language'] ?? 'Change language',
      changeTheme: json['change_theme'] ?? 'Change theme',
      highlightsTitle: json['highlights_title'] ?? 'Key Highlights:',
      impactLabel: json['impact_label'] ?? 'Impact:',
      viewOrganization: json['view_organization'] ?? 'View Organization',
      linkedinButton: json['linkedin_button'] ?? 'LinkedIn',
      monthNames: List<String>.from(json['month_names'] ?? ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']),
      socialLabels: SocialLabels.fromJson(json['social_labels'] ?? {}),
    );
  }
}

class ContactTexts {
  final String letsConnect;
  final String coffeeQuestion;
  final String projectDescription;
  final String followSocial;
  final String openOpportunities;
  final String sendMessage;

  ContactTexts({
    required this.letsConnect,
    required this.coffeeQuestion,
    required this.projectDescription,
    required this.followSocial,
    required this.openOpportunities,
    required this.sendMessage,
  });

  factory ContactTexts.fromJson(Map<String, dynamic> json) {
    return ContactTexts(
      letsConnect: json['lets_connect'] ?? 'Conectemos',
      coffeeQuestion: json['coffee_question'] ?? '¿Tomamos un café?',
      projectDescription: json['project_description'] ?? '¿Tienes un proyecto en mente o quieres colaborar? Me encantaría escuchar de ti.',
      followSocial: json['follow_social'] ?? 'Sígueme en redes sociales',
      openOpportunities: json['open_opportunities'] ?? 'Siempre estoy abierto a discutir nuevas oportunidades, proyectos interesantes o simplemente charlar sobre tecnología.',
      sendMessage: json['send_message'] ?? 'Enviar mensaje',
    );
  }
}

class AboutTexts {
  final String myStory;
  final String locationLabel;
  final String titleLabel;
  final String emailLabel;

  AboutTexts({
    required this.myStory,
    required this.locationLabel,
    required this.titleLabel,
    required this.emailLabel,
  });

  factory AboutTexts.fromJson(Map<String, dynamic> json) {
    return AboutTexts(
      myStory: json['my_story'] ?? 'Mi Historia',
      locationLabel: json['location_label'] ?? 'Ubicación',
      titleLabel: json['title_label'] ?? 'Título',
      emailLabel: json['email_label'] ?? 'Email',
    );
  }
}

class FooterConfig {
  final String tagline;
  final String connectTitle;
  final String copyrightText;
  final String madeWithText;
  final String withText;

  FooterConfig({
    required this.tagline,
    required this.connectTitle,
    required this.copyrightText,
    required this.madeWithText,
    required this.withText,
  });

  factory FooterConfig.fromJson(Map<String, dynamic> json) {
    return FooterConfig(
      tagline: json['tagline'],
      connectTitle: json['connect_title'],
      copyrightText: json['copyright_text'],
      madeWithText: json['made_with_text'],
      withText: json['with_text'],
    );
  }
}

class MetaConfig {
  final String siteUrl;
  final String title;
  final String description;
  final String keywords;
  final String structuredDescription;
  final String siteName;
  final String locale;
  final String langCode;
  final String twitterHandle;
  final String organization;
  final String organizationUrl;
  final String city;
  final String country;
  final String education;

  MetaConfig({
    required this.siteUrl,
    required this.title,
    required this.description,
    required this.keywords,
    required this.structuredDescription,
    required this.siteName,
    required this.locale,
    required this.langCode,
    required this.twitterHandle,
    required this.organization,
    required this.organizationUrl,
    required this.city,
    required this.country,
    required this.education,
  });

  factory MetaConfig.fromJson(Map<String, dynamic> json) {
    return MetaConfig(
      siteUrl: json['site_url'],
      title: json['title'],
      description: json['description'],
      keywords: json['keywords'],
      structuredDescription: json['structured_description'],
      siteName: json['site_name'],
      locale: json['locale'],
      langCode: json['lang_code'],
      twitterHandle: json['twitter_handle'],
      organization: json['organization'],
      organizationUrl: json['organization_url'],
      city: json['city'],
      country: json['country'],
      education: json['education'],
    );
  }
}

class LanguageInfo {
  final String code;
  final String name;

  LanguageInfo({
    required this.code,
    required this.name,
  });

  factory LanguageInfo.fromJson(Map<String, dynamic> json) {
    return LanguageInfo(
      code: json['code'],
      name: json['name'],
    );
  }
}

class ElevationConfig {
  final ElevationLevel level1;
  final ElevationLevel level2;
  final ElevationLevel level3;
  final ElevationLevel level4;

  ElevationConfig({
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
  });

  factory ElevationConfig.fromJson(Map<String, dynamic> json) {
    return ElevationConfig(
      level1: ElevationLevel.fromJson(json['level_1']),
      level2: ElevationLevel.fromJson(json['level_2']),
      level3: ElevationLevel.fromJson(json['level_3']),
      level4: ElevationLevel.fromJson(json['level_4']),
    );
  }
}

class ElevationLevel {
  final double blurRadius;
  final double offsetY;
  final double opacity;

  ElevationLevel({
    required this.blurRadius,
    required this.offsetY,
    required this.opacity,
  });

  factory ElevationLevel.fromJson(Map<String, dynamic> json) {
    return ElevationLevel(
      blurRadius: (json['blur_radius']).toDouble(),
      offsetY: (json['offset_y']).toDouble(),
      opacity: (json['opacity']).toDouble(),
    );
  }
}

class NavigationConfig {
  final int hoverAnimationDuration;
  final double hoverBackgroundOpacity;
  final double activeBackgroundOpacity;
  final bool showActiveBorder;

  NavigationConfig({
    required this.hoverAnimationDuration,
    required this.hoverBackgroundOpacity,
    required this.activeBackgroundOpacity,
    required this.showActiveBorder,
  });

  factory NavigationConfig.fromJson(Map<String, dynamic> json) {
    return NavigationConfig(
      hoverAnimationDuration: json['hover_animation_duration'] ?? 200,
      hoverBackgroundOpacity: json['hover_background_opacity']?.toDouble() ?? 0.1,
      activeBackgroundOpacity: json['active_background_opacity']?.toDouble() ?? 0.15,
      showActiveBorder: json['show_active_border'] ?? true,
    );
  }
}

class Education {
  final String institution;
  final String degree;
  final String field;
  final String duration;

  Education({
    required this.institution,
    required this.degree,
    required this.field,
    required this.duration,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      institution: json['institution'],
      degree: json['degree'],
      field: json['field'],
      duration: json['duration'],
    );
  }
}