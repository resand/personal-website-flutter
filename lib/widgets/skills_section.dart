import 'package:flutter/material.dart';
import '../models/website_config.dart';
import '../utils/responsive_utils.dart';
import 'section_header.dart';

class SkillsSection extends StatelessWidget {
  final MyWebsiteConfig config;

  const SkillsSection({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Container(
      padding: ResponsiveUtils.sectionPadding(context),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: ResponsiveUtils.sectionMaxWidth),
          child: Column(
            children: [
              SectionHeader(title: config.layout.sectionTitles.skills),
              _buildSkillCategories(context, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillCategories(BuildContext context, bool isMobile) {
    final categories = config.skills.categories;
    
    if (isMobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: categories.map((category) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildSkillCategory(context, category, isMobile),
          ),
        ).toList(),
      );
    } else {
      return Wrap(
        spacing: 24,
        runSpacing: 20,
        children: categories.map((category) => 
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 550, // Max width for two columns
            ),
            child: _buildSkillCategory(context, category, false),
          ),
        ).toList(),
      );
    }
  }

  Widget _buildSkillCategory(BuildContext context, SkillCategory category, bool isMobile) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: isDarkMode ? 0.1 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with small icon and title
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Skills as flowing text
          Text(
            category.skills.map((skill) => skill.name).join(' • '),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }


}