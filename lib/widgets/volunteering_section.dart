import 'package:flutter/material.dart';
import '../models/website_config.dart';
import '../utils/responsive_utils.dart';
import '../utils/elevation_utils.dart';
import '../utils/url_helper.dart';
import 'section_header.dart';

class VolunteeringSection extends StatelessWidget {
  final MyWebsiteConfig config;

  const VolunteeringSection({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.sectionPadding(context),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: ResponsiveUtils.sectionMaxWidth),
          child: Column(
            children: [
              SectionHeader(title: config.layout.sectionTitles.volunteering),
              ResponsiveUtils.isMobile(context)
                ? Column(
                    children: config.volunteering.map((volunteering) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildVolunteeringCard(context, volunteering),
                      ),
                    ).toList(),
                  )
                : Wrap(
                    spacing: 32,
                    runSpacing: 32,
                    alignment: WrapAlignment.center,
                    children: config.volunteering.map((volunteering) => 
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: (1200 - 32) / 2, // Max container width minus spacing, divided by 2
                        ),
                        child: _buildVolunteeringCard(context, volunteering),
                      ),
                    ).toList(),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVolunteeringCard(BuildContext context, Volunteering volunteering) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ElevationUtils.getCardElevation(
          elevationConfig: config.theme.elevation,
          level: 2,
          isDarkMode: isDarkMode,
        ),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.volunteer_activism,
                    color: Theme.of(context).colorScheme.primary,
                    size: isMobile ? 20 : 24,
                  ),
                ),
                SizedBox(width: isMobile ? 4 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        volunteering.role,
                        style: (isMobile
                                ? Theme.of(context).textTheme.titleMedium
                                : Theme.of(context).textTheme.headlineSmall)
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        volunteering.organization,
                        style: (isMobile
                                ? Theme.of(context).textTheme.bodyMedium
                                : Theme.of(context).textTheme.titleMedium)
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 10 : 12,
                vertical: isMobile ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                volunteering.duration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              volunteering.description,
              style: (isMobile
                      ? Theme.of(context).textTheme.bodyMedium
                      : Theme.of(context).textTheme.bodyLarge)
                  ?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Theme.of(context).colorScheme.primary,
                    size: isMobile ? 18 : 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          config.layout.uiTexts.impactLabel,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          volunteering.impact,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (volunteering.website?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: OutlinedButton.icon(
                    onPressed: () => UrlHelper.open(volunteering.website!, context: context),
                    icon: const Icon(Icons.language, size: 16),
                    label: Text(config.layout.uiTexts.viewOrganization),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 10 : 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
    );
  }
}