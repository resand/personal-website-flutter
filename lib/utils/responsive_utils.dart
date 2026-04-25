import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileMaxWidth = 768;
  static const double tabletMaxWidth = 1024;

  static const double sectionMaxWidth = 1200;
  static const double sectionMaxWidthNarrow = 800;

  static const double sectionVerticalMobile = 48;
  static const double sectionVerticalTablet = 64;
  static const double sectionVerticalDesktop = 80;

  static const double sectionHorizontalMobile = 20;
  static const double sectionHorizontalTablet = 32;
  static const double sectionHorizontalDesktop = 40;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= mobileMaxWidth;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > mobileMaxWidth && width <= tabletMaxWidth;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > tabletMaxWidth;
  }

  static int getCrossAxisCount(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3}) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  static EdgeInsets sectionPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(
        vertical: sectionVerticalMobile,
        horizontal: sectionHorizontalMobile,
      );
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(
        vertical: sectionVerticalTablet,
        horizontal: sectionHorizontalTablet,
      );
    } else {
      return const EdgeInsets.symmetric(
        vertical: sectionVerticalDesktop,
        horizontal: sectionHorizontalDesktop,
      );
    }
  }

  static double valueFor(
    BuildContext context, {
    required double mobile,
    double? tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? desktop;
    return desktop;
  }
}
