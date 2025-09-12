import '../models/website_config.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

class MetaService {
  static final Logger _logger = Logger();
  static String generateSocialLinksJson(List<SocialLink> socialLinks) {
    final urls = socialLinks.map((link) {
      switch (link.platform) {
        case 'github':
          return 'https://github.com/${link.url.split('/').last}';
        case 'linkedin':
          return 'https://linkedin.com/in/${link.url.split('/').last}';
        case 'medium':
          return 'https://medium.com/@${link.url.split('@').last}';
        case 'x':
        case 'twitter':
          return 'https://x.com/${link.url.split('/').last}';
        default:
          return link.url;
      }
    }).toList();
    
    return jsonEncode(urls);
  }
  
  static String generateSkillsJson(Skills skills) {
    final skillNames = <String>[];
    
    for (final category in skills.categories) {
      for (final skill in category.skills) {
        skillNames.add(skill.name);
      }
    }
    
    return jsonEncode(skillNames.take(10).toList()); // Top 10 skills
  }
  
  static Map<String, String> getMetaReplacements(MyWebsiteConfig config) {
    return {
      'LANG_CODE': config.meta.langCode,
      'META_TITLE': config.meta.title,
      'META_DESCRIPTION': config.meta.description,
      'META_KEYWORDS': config.meta.keywords,
      'AUTHOR_NAME': config.personalInfo.name,
      'SITE_URL': config.meta.siteUrl,
      'SITE_NAME': config.meta.siteName,
      'LOCALE': config.meta.locale,
      'AVATAR_URL': config.personalInfo.avatarUrl,
      'TWITTER_HANDLE': config.meta.twitterHandle,
      'JOB_TITLE': config.personalInfo.title,
      'STRUCTURED_DESCRIPTION': config.meta.structuredDescription,
      'SOCIAL_LINKS_JSON': generateSocialLinksJson(config.socialLinks.links),
      'ORGANIZATION': config.meta.organization,
      'ORGANIZATION_URL': config.meta.organizationUrl,
      'SKILLS_JSON': generateSkillsJson(config.skills),
      'EDUCATION': config.meta.education,
      'CITY': config.meta.city,
      'COUNTRY': config.meta.country,
    };
  }
  
  static void updateMetaTags(MyWebsiteConfig config) {
    // This would be used to dynamically update meta tags in the browser
    // For Flutter Web, we would need to use dart:html to update the DOM
    
    try {
      // Update document title
      _updateTitle(config.meta.title);
      
      // Update meta tags
      final replacements = getMetaReplacements(config);
      _updateMetaTags(replacements);
      
      // Update Open Graph tags
      _updateOpenGraphTags(replacements);
      
      // Update Twitter Card tags
      _updateTwitterTags(replacements);
      
    } catch (e) {
      _logger.w('Failed to update meta tags: $e');
    }
  }
  
  static void _updateTitle(String title) {
    try {
      // Using dart:html would be: document.title = title;
      // For now, we'll use a platform-agnostic approach
      _logger.i('Would update title to: $title');
    } catch (e) {
      _logger.w('Failed to update title: $e');
    }
  }
  
  static void _updateMetaTags(Map<String, String> replacements) {
    // Update basic meta tags
    _updateMetaTag('description', replacements['META_DESCRIPTION']!);
    _updateMetaTag('keywords', replacements['META_KEYWORDS']!);
    _updateMetaTag('author', replacements['AUTHOR_NAME']!);
    
    _logger.i('Updated basic meta tags');
  }
  
  static void _updateOpenGraphTags(Map<String, String> replacements) {
    // Update Open Graph tags
    _updateMetaProperty('og:title', replacements['META_TITLE']!);
    _updateMetaProperty('og:description', replacements['META_DESCRIPTION']!);
    _updateMetaProperty('og:url', replacements['SITE_URL']!);
    _updateMetaProperty('og:image', replacements['AVATAR_URL']!);
    _updateMetaProperty('og:site_name', replacements['SITE_NAME']!);
    _updateMetaProperty('og:locale', replacements['LOCALE']!);
    
    _logger.i('Updated Open Graph tags');
  }
  
  static void _updateTwitterTags(Map<String, String> replacements) {
    // Update Twitter Card tags
    _updateMetaProperty('twitter:title', replacements['META_TITLE']!);
    _updateMetaProperty('twitter:description', replacements['META_DESCRIPTION']!);
    _updateMetaProperty('twitter:image', replacements['AVATAR_URL']!);
    _updateMetaProperty('twitter:creator', replacements['TWITTER_HANDLE']!);
    
    _logger.i('Updated Twitter Card tags');
  }
  
  static void _updateMetaTag(String name, String content) {
    // Platform-specific implementation would go here
    // For dart:html: querySelector('meta[name="$name"]')?.setAttribute('content', content);
    _logger.d('Would update meta[$name] = $content');
  }
  
  static void _updateMetaProperty(String property, String content) {
    // Platform-specific implementation would go here  
    // For dart:html: querySelector('meta[property="$property"]')?.setAttribute('content', content);
    _logger.d('Would update meta[property="$property"] = $content');
  }
}