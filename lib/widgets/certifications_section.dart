import 'package:flutter/material.dart';
import '../models/website_config.dart';
import '../utils/responsive_utils.dart';
import '../utils/elevation_utils.dart';

class CertificationsSection extends StatelessWidget {
  final MyWebsiteConfig config;

  const CertificationsSection({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    if (config.certifications == null || config.certifications!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                config.layout.sectionTitles.certifications,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
              _buildCertificationsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificationsList(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
      child: isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    // For desktop, show in a 2-column grid with flexible height
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 16,
        childAspectRatio: 4, // Increased from 6 to allow more height
      ),
      itemCount: config.certifications!.length,
      itemBuilder: (context, index) {
        return _buildCertificationItem(context, config.certifications![index]);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    // For mobile, show in a single column
    return Column(
      children: config.certifications!.asMap().entries.map((entry) {
        final index = entry.key;
        final certification = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index == config.certifications!.length - 1 ? 0 : 16),
          child: _buildCertificationItem(context, certification),
        );
      }).toList(),
    );
  }

  Widget _buildCertificationItem(BuildContext context, String certification) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Certificate icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.verified,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          // Certification text
          Expanded(
            child: Text(
              certification,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}