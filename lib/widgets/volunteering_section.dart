import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/website_config.dart';
import '../utils/responsive_utils.dart';
import '../utils/elevation_utils.dart';

class VolunteeringSection extends StatelessWidget {
  final MyWebsiteConfig config;

  const VolunteeringSection({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                config.layout.sectionTitles.volunteering,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 48),
              // Use a more flexible layout for varying content heights
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: isMobile ? 12 : null,
                        ),
                      ),
                      SizedBox(height: isMobile ? 1 : 4),
                      Text(
                        volunteering.organization,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 12 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 6 : 12),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12, 
                vertical: isMobile ? 3 : 6
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
                  fontSize: isMobile ? 9 : null,
                ),
              ),
            ),
            SizedBox(height: isMobile ? 6 : 12),
            Text(
              volunteering.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.4,
                fontSize: isMobile ? 12 : null,
              ),
            ),
            SizedBox(height: isMobile ? 6 : 12),
            Container(
              padding: EdgeInsets.all(isMobile ? 6 : 16),
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
                    size: isMobile ? 16 : 20,
                  ),
                  SizedBox(width: isMobile ? 6 : 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          config.layout.uiTexts.impactLabel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: isMobile ? 9 : null,
                          ),
                        ),
                        SizedBox(height: isMobile ? 1 : 4),
                        Text(
                          volunteering.impact,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                            fontSize: isMobile ? 12 : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (volunteering.website?.isNotEmpty == true) ...[
              SizedBox(height: isMobile ? 8 : 12),
              SizedBox(
                width: double.infinity,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: OutlinedButton.icon(
                    onPressed: () => _launchUrl(volunteering.website!),
                    icon: Icon(Icons.language, size: isMobile ? 14 : 16),
                    label: Text(
                      config.layout.uiTexts.viewOrganization,
                      style: TextStyle(fontSize: isMobile ? 12 : null),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 8 : 12
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

  Future<void> _launchUrl(String url) async {
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }
}