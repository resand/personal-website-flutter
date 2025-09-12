import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/website_config.dart';
import '../utils/responsive_utils.dart';

class MyWebsiteFooter extends StatelessWidget {
  final MyWebsiteConfig config;
  final Function(String)? onSectionTap;

  const MyWebsiteFooter({
    super.key, 
    required this.config,
    this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              if (!isMobile)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildBrandSection(context),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 1,
                      child: _buildSocialSection(context),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildBrandSection(context),
                    const SizedBox(height: 32),
                    _buildSocialSection(context),
                  ],
                ),
              const SizedBox(height: 32),
              Divider(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 24),
              isMobile
                  ? Column(
                      children: [
                        _buildCopyright(context),
                        const SizedBox(height: 8),
                        _buildCredits(context),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCopyright(context),
                        _buildCredits(context),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildBrandSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogoOrName(context),
        const SizedBox(height: 8),
        Text(
          config.personalInfo.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
          ),
        ),
        Text(
          config.footer.tagline,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoOrName(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final logoHeight = config.layout.logoHeight * 0.7; // Slightly smaller for footer
    
    // Determine which logo to use
    String? logoUrl;
    if (config.personalInfo.logoLightUrl != null && config.personalInfo.logoDarkUrl != null) {
      // Use theme-specific logo
      logoUrl = isDarkMode ? config.personalInfo.logoDarkUrl : config.personalInfo.logoLightUrl;
    } else if (config.personalInfo.logoLightUrl != null) {
      // Only light logo available
      logoUrl = config.personalInfo.logoLightUrl;
    } else if (config.personalInfo.logoDarkUrl != null) {
      // Only dark logo available
      logoUrl = config.personalInfo.logoDarkUrl;
    }
    
    if (logoUrl != null && logoUrl.isNotEmpty) {
      // Check if it's a network URL or local asset
      final isNetworkImage = logoUrl.startsWith('http://') || logoUrl.startsWith('https://');
      
      if (isNetworkImage) {
        return Image.network(
          logoUrl,
          height: logoHeight,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              config.personalInfo.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            );
          },
        );
      } else {
        // For web production, treat local paths as web root paths
        final webUrl = logoUrl.startsWith('/') ? logoUrl : '/$logoUrl';
        return Image.network(
          webUrl,
          height: logoHeight,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              config.personalInfo.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            );
          },
        );
      }
    } else {
      // No logo available, use text
      return Text(
        config.personalInfo.name,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }



  Widget _buildSocialSection(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          config.footer.connectTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: isMobile ? WrapAlignment.start : WrapAlignment.end,
          children: config.socialLinks.links.where((link) => link.url.isNotEmpty).map((socialLink) {
            IconData icon;
            switch (socialLink.platform.toLowerCase()) {
              case 'linkedin':
                icon = FontAwesomeIcons.linkedin;
                break;
              case 'github':
                icon = FontAwesomeIcons.github;
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
              default:
                icon = FontAwesomeIcons.link;
            }
            return _buildSocialIcon(context, icon, socialLink.url);
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: isMobile ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            FaIcon(
              FontAwesomeIcons.google,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _launchUrl('mailto:${config.personalInfo.email}'),
                child: Text(
                  config.personalInfo.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon, String url) {
    return _SocialIconHoverable(
      icon: icon,
      url: url,
      onTap: _launchUrl,
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Text(
      '© ${DateTime.now().year} ${config.personalInfo.name}. ${config.footer.copyrightText}.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCredits(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${config.footer.madeWithText} ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        Icon(
          Icons.favorite,
          size: 15,
          color: Theme.of(context).colorScheme.error,
        ),
        Text(
          ' ${config.footer.withText} ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        FlutterLogo(size: 15),
      ],
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


class _SocialIconHoverable extends StatefulWidget {
  final IconData icon;
  final String url;
  final Function(String) onTap;

  const _SocialIconHoverable({
    required this.icon,
    required this.url,
    required this.onTap,
  });

  @override
  State<_SocialIconHoverable> createState() => _SocialIconHoverableState();
}

class _SocialIconHoverableState extends State<_SocialIconHoverable> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.url),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHovered 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(
            widget.icon,
            size: 20,
            color: isHovered 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}