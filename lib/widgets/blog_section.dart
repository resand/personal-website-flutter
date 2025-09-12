import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/website_config.dart';
import '../models/blog_post.dart';
import '../services/blog_service.dart';
import '../utils/responsive_utils.dart';
import '../utils/elevation_utils.dart';

class BlogSection extends StatefulWidget {
  final MyWebsiteConfig config;

  const BlogSection({super.key, required this.config});

  @override
  State<BlogSection> createState() => _BlogSectionState();
}

class _BlogSectionState extends State<BlogSection> {
  List<BlogPost>? posts;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.config.mediumConfig.showLatestPosts) {
      _loadPosts();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadPosts() async {
    try {
      final loadedPosts = await BlogService.fetchAllPosts(widget.config.blogConfig);
      
      if (mounted) {
        setState(() {
          posts = loadedPosts;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.config.mediumConfig.showLatestPosts) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      widget.config.blogConfig.sectionTitle,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.config.blogConfig.sectionDescription,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildContent(),
              const SizedBox(height: 32),
              _buildViewAllButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            widget.config.blogConfig.errorTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.config.blogConfig.errorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }

    if (posts?.isEmpty ?? true) {
      return Column(
        children: [
          Icon(
            Icons.article_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            widget.config.blogConfig.emptyMessage,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      );
    }

    // Use flexible layout for varying content heights
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        children: posts!.map((post) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _BlogCardStateful(
              post: post, 
              isMobile: true,
              config: widget.config,
            ),
          ),
        ).toList(),
      );
    } else {
      return Wrap(
        spacing: 24,
        runSpacing: 24,
        children: posts!.map((post) => 
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 360, // Max width for three columns
            ),
            child: _BlogCardStateful(
              post: post, 
              isMobile: false,
              config: widget.config,
            ),
          ),
        ).toList(),
      );
    }
  }

  Widget _buildViewAllButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: OutlinedButton.icon(
        onPressed: () => _launchUrl(widget.config.socialLinks.medium ?? 'https://medium.com/@${widget.config.mediumConfig.username}'),
        icon: const Icon(Icons.launch, size: 18),
        label: Text(widget.config.blogConfig.viewAllText),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          foregroundColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
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

class _BlogCardStateful extends StatefulWidget {
  final BlogPost post;
  final bool isMobile;
  final MyWebsiteConfig config;

  const _BlogCardStateful({
    required this.post, 
    required this.isMobile,
    required this.config,
  });

  @override
  State<_BlogCardStateful> createState() => _BlogCardStatefulState();
}

class _BlogCardStatefulState extends State<_BlogCardStateful> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () => _launchUrl(widget.post.url),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ElevationUtils.getCardElevation(
              elevationConfig: widget.config.theme.elevation,
              level: isHovered ? 3 : 2,
              isDarkMode: isDarkMode,
            ),
            border: Border.all(
              color: isHovered 
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          transform: isHovered 
            ? (Matrix4.identity()..setTranslationRaw(0.0, -2.0, 0.0))
            : Matrix4.identity(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image section
              Container(
                height: widget.isMobile ? 120 : 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: widget.post.imageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        widget.post.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                      ),
                    )
                  : _buildPlaceholderImage(),
              ),
              // Content section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getSourceColor(widget.post.source).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(
                                  _getSourceIcon(widget.post.source),
                                  size: 12,
                                  color: _getSourceColor(widget.post.source),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    widget.post.source,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: _getSourceColor(widget.post.source),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.post.getReadTimeText(widget.config.layout.uiTexts.minReadText),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.post.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.post.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.3,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                          ),
                          maxLines: widget.isMobile ? 5 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.post.getFormattedDate(widget.config.layout.uiTexts.monthNames),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    if (widget.post.categories.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: widget.post.categories.take(2).map((category) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 9,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
          ]),
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

  IconData _getSourceIcon(String source) {
    switch (source.toLowerCase()) {
      case 'dev.to':
        return FontAwesomeIcons.dev;
      case 'medium':
        return FontAwesomeIcons.medium;
      default:
        return FontAwesomeIcons.newspaper;
    }
  }

  Color _getSourceColor(String source) {
    switch (source.toLowerCase()) {
      case 'dev.to':
        return Theme.of(context).colorScheme.onSurface;
      case 'medium':
        return Theme.of(context).colorScheme.primary;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Icon(
        Icons.article_outlined,
        size: 48,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }
}