import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/website_config.dart';
import '../utils/responsive_utils.dart';

class HeroSection extends StatelessWidget {
  final MyWebsiteConfig config;

  const HeroSection({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Container(
      padding: const EdgeInsets.all(40),
      constraints: const BoxConstraints(minHeight: 600),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildContent(context),
        ),
        const SizedBox(width: 80),
        Expanded(
          flex: 1,
          child: _buildAvatar(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAvatar(context),
        const SizedBox(height: 40),
        _buildContent(context),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          config.layout.heroTexts.greeting,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          config.personalInfo.name,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          config.personalInfo.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (config.personalInfo.funFact?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          _buildFunFactBadge(context),
        ],
        const SizedBox(height: 16),
        Text(
          config.personalInfo.subtitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          config.personalInfo.shortBio ?? config.personalInfo.bio,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ElevatedButton.icon(
            onPressed: () => _launchUrl('mailto:${config.personalInfo.email}'),
            icon: const FaIcon(FontAwesomeIcons.google, size: 18),
            label: Text(config.layout.heroTexts.contactButton),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildSocialLinks(context),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 150,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          backgroundImage: config.personalInfo.avatarUrl.startsWith('http')
              ? NetworkImage(config.personalInfo.avatarUrl)
              : AssetImage(config.personalInfo.avatarUrl) as ImageProvider,
                child: config.personalInfo.avatarUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 100,
                        color: Theme.of(context).colorScheme.onSurface,
                      )
                    : null,
        ),
      ),
    );
  }

  Widget _buildFunFactBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.construction,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${config.personalInfo.funFact}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: config.socialLinks.links.where((link) => link.url.isNotEmpty).map((socialLink) {
        final labelKey = socialLink.platform.toLowerCase();
        String label;
        switch (labelKey) {
          case 'linkedin':
            label = config.layout.uiTexts.socialLabels.linkedin;
            break;
          case 'github':
            label = config.layout.uiTexts.socialLabels.github;
            break;
          case 'x':
            label = config.layout.uiTexts.socialLabels.x;
            break;
          case 'medium':
            label = config.layout.uiTexts.socialLabels.medium;
            break;
          case 'instagram':
            label = config.layout.uiTexts.socialLabels.instagram;
            break;
          default:
            label = socialLink.platform;
        }
        return _buildSocialIcon(context, label, socialLink.url);
      }).toList(),
    );
  }

  Widget _buildSocialIcon(BuildContext context, String platform, String url) {
    IconData icon;
    switch (platform.toLowerCase()) {
      case 'github':
        icon = FontAwesomeIcons.github;
        break;
      case 'linkedin':
        icon = FontAwesomeIcons.linkedin;
        break;
      case 'x':
        icon = FontAwesomeIcons.xTwitter;
        break;
      case 'medium':
        icon = FontAwesomeIcons.medium;
        break;
      case 'instagram':
        icon = FontAwesomeIcons.instagram;
        break;
      case 'website':
        icon = FontAwesomeIcons.globe;
        break;
      default:
        icon = FontAwesomeIcons.link;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          onPressed: () => _launchUrl(url),
          icon: FaIcon(icon),
          tooltip: platform,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            foregroundColor: Theme.of(context).colorScheme.primary,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered)) {
                  return Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }
}