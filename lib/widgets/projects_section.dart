import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/website_config.dart';
import '../utils/responsive_utils.dart';

class ProjectsSection extends StatelessWidget {
  final MyWebsiteConfig config;

  const ProjectsSection({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 80,
        horizontal: isMobile ? 20 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                config.layout.sectionTitles.projects,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
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
              const SizedBox(height: 48),
              _buildProjectGrid(context, config.projects, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectGrid(
    BuildContext context,
    List<Project> projects,
    bool isMobile,
  ) {
    if (isMobile) {
      // Use Column for mobile to allow natural height adjustment
      return Column(
        children: projects
            .map(
              (project) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildProjectCard(context, project),
              ),
            )
            .toList(),
      );
    } else {
      // Use Wrap for desktop/tablet like skills section - allows natural height
      final isTablet = ResponsiveUtils.isTablet(context);
      final crossAxisCount = isTablet ? 2 : 3;
      final maxWidth = (1200 - (crossAxisCount - 1) * 24) / crossAxisCount;
      
      return Wrap(
        spacing: 24,
        runSpacing: 24,
        children: projects.map((project) => 
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: _buildProjectCard(context, project),
          ),
        ).toList(),
      );
    }
  }

  Widget _buildProjectCard(
    BuildContext context,
    Project project,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProjectImage(context, project),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    project.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: project.technologies
                        .take(3)
                        .map(
                          (tech) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tech,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (project.githubUrl?.isNotEmpty == true)
                      Flexible(
                        child: OutlinedButton.icon(
                          onPressed: () => _launchUrl(project.githubUrl!),
                          icon: const FaIcon(FontAwesomeIcons.github, size: 16),
                          label: Text(
                            config.layout.uiTexts.codeButton,
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            minimumSize: const Size(0, 40),
                          ),
                        ),
                      ),
                    if (project.githubUrl?.isNotEmpty == true &&
                        project.liveUrl?.isNotEmpty == true)
                      const SizedBox(width: 6),
                    if (project.liveUrl?.isNotEmpty == true)
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchUrl(project.liveUrl!),
                          icon: const Icon(Icons.launch, size: 16),
                          label: Text(
                            config.layout.uiTexts.viewButton,
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            minimumSize: const Size(0, 40),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectImage(BuildContext context, Project project) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        width: double.infinity,
        height: ResponsiveUtils.isMobile(context) ? 180 : 200,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: project.imageUrl?.isNotEmpty == true
            ? (project.imageUrl!.startsWith('http')
                  ? Image.network(
                      project.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(context),
                    )
                  : Image.network(
                      project.imageUrl!.startsWith('/') ? project.imageUrl! : '/${project.imageUrl!}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset(
                            project.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error2, stackTrace2) =>
                                _buildPlaceholderImage(context),
                          ),
                    ))
            : _buildPlaceholderImage(context),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: FaIcon(
        FontAwesomeIcons.globe,
        size: 64,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
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
