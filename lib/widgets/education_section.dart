import 'package:flutter/material.dart';
import '../models/website_config.dart';
import '../utils/responsive_utils.dart';
import '../utils/elevation_utils.dart';
import 'section_header.dart';

class EducationSection extends StatelessWidget {
  final MyWebsiteConfig config;

  const EducationSection({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    if (config.education == null || config.education!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: ResponsiveUtils.sectionPadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: ResponsiveUtils.sectionMaxWidth),
          child: Column(
            children: [
              SectionHeader(title: config.layout.sectionTitles.education),
              _buildEducationList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEducationList(BuildContext context) {
    final useStackedLayout = !ResponsiveUtils.isDesktop(context);

    return Column(
      children: config.education!.asMap().entries.map((entry) {
        final index = entry.key;
        final education = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index == config.education!.length - 1 ? 0 : 24),
          child: _buildEducationCard(context, education, useStackedLayout),
        );
      }).toList(),
    );
  }

  Widget _buildEducationCard(BuildContext context, Education education, bool useStackedLayout) {
    final isMobile = ResponsiveUtils.isMobile(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ElevationUtils.getCardElevation(
          elevationConfig: config.theme.elevation,
          level: 2,
          shadowColor: Theme.of(context).shadowColor,
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
        ),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: useStackedLayout
          ? _buildMobileLayout(context, education)
          : _buildDesktopLayout(context, education),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, Education education) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Institution and duration
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  education.duration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                education.institution,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Right side - Degree and field
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                education.degree,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              ),
              const SizedBox(height: 8),
              Text(
                education.field,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, Education education) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Duration badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            education.duration,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Degree
        Text(
          education.degree,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Field
        Text(
          education.field,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        // Institution
        Text(
          education.institution,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}