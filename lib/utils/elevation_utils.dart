import 'package:flutter/material.dart';
import '../models/website_config.dart';

class ElevationUtils {
  static BoxShadow createShadow({
    required ElevationLevel level,
    required Color shadowColor,
  }) {
    return BoxShadow(
      color: shadowColor.withValues(alpha: level.opacity),
      blurRadius: level.blurRadius,
      offset: Offset(0, level.offsetY),
    );
  }

  static List<BoxShadow> createElevation({
    required ElevationLevel level,
    Color? shadowColor,
    bool isDarkMode = false,
  }) {
    // The shadowColor should already come from context, if not pass a default one
    final color = shadowColor ?? (isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black);
    
    return [
      createShadow(level: level, shadowColor: color),
    ];
  }

  static List<BoxShadow> getCardElevation({
    required ElevationConfig elevationConfig,
    int level = 2,
    Color? shadowColor,
    bool isDarkMode = false,
  }) {
    ElevationLevel elevationLevel;
    
    switch (level) {
      case 1:
        elevationLevel = elevationConfig.level1;
        break;
      case 2:
        elevationLevel = elevationConfig.level2;
        break;
      case 3:
        elevationLevel = elevationConfig.level3;
        break;
      case 4:
        elevationLevel = elevationConfig.level4;
        break;
      default:
        elevationLevel = elevationConfig.level2;
    }
    
    return createElevation(
      level: elevationLevel,
      shadowColor: shadowColor,
      isDarkMode: isDarkMode,
    );
  }
}