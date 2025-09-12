import 'package:flutter/material.dart';
import '../utils/theme_types.dart';
import '../models/website_config.dart';
import '../utils/responsive_utils.dart';

class ThemeSelectorHover extends StatefulWidget {
  final ThemeModeType themeMode;
  final Function(ThemeModeType) onThemeChanged;
  final Function(Offset?) onThemeToggle;
  final String? tooltip;
  final MyWebsiteConfig config;

  const ThemeSelectorHover({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onThemeToggle,
    required this.config,
    this.tooltip,
  });

  @override
  State<ThemeSelectorHover> createState() => _ThemeSelectorHoverState();
}

class _ThemeSelectorHoverState extends State<ThemeSelectorHover>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onThemeSelected(ThemeModeType themeMode) {
    if (themeMode != widget.themeMode) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      widget.onThemeToggle(null);
      widget.onThemeChanged(themeMode);
    }
  }

  IconData _getThemeIcon(ThemeModeType themeMode) {
    switch (themeMode) {
      case ThemeModeType.auto:
        return Icons.brightness_auto;
      case ThemeModeType.light:
        return Icons.light_mode;
      case ThemeModeType.dark:
        return Icons.dark_mode;
    }
  }

  Color _getThemeColor(ThemeModeType themeMode) {
    switch (themeMode) {
      case ThemeModeType.auto:
        return Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? 
               Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
      case ThemeModeType.light:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8);
      case ThemeModeType.dark:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _getThemeText(ThemeModeType themeMode) {
    switch (themeMode) {
      case ThemeModeType.auto:
        return widget.config.layout.uiTexts.themeAuto;
      case ThemeModeType.light:
        return widget.config.layout.uiTexts.themeLight;
      case ThemeModeType.dark:
        return widget.config.layout.uiTexts.themeDark;
    }
  }

  Widget _buildDropdownOption(ThemeModeType themeMode, {bool isActive = false}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onThemeSelected(themeMode),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isActive
                ? _getThemeColor(themeMode).withValues(alpha: 0.1)
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: _getThemeColor(themeMode).withValues(alpha: 0.15),
                ),
                child: Icon(
                  _getThemeIcon(themeMode),
                  color: _getThemeColor(themeMode),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getThemeText(themeMode),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? _getThemeColor(themeMode) : null,
                  ),
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle,
                  color: _getThemeColor(themeMode),
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeChip(ThemeModeType themeMode, bool isFirst, bool isLast) {
    final isActive = widget.themeMode == themeMode;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onThemeSelected(themeMode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive 
              ? _getThemeColor(themeMode).withValues(alpha: 0.2)
              : _getThemeColor(themeMode).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _opacityAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: isActive ? (_pulseAnimation.value * 0.05 + 0.95) : 1.0,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: Center(
                    child: Icon(
                      _getThemeIcon(themeMode),
                      size: 14,
                      color: _getThemeColor(themeMode),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(ThemeModeType themeMode, {bool isActive = false, bool isVisible = true}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isVisible ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _onThemeSelected(themeMode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isActive 
                  ? _getThemeColor(themeMode).withValues(alpha: 0.2)
                  : _getThemeColor(themeMode).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: AnimatedBuilder(
                animation: Listenable.merge([_pulseAnimation, _opacityAnimation]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: isActive ? _pulseAnimation.value : 1.0,
                    child: Opacity(
                      opacity: isActive ? _opacityAnimation.value : 1.0,
                      child: Icon(
                        _getThemeIcon(themeMode),
                        size: 16,
                        color: _getThemeColor(themeMode),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    if (isMobile) {
      // Mobile: compact chips to prevent overflow - matching language selector
      return IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < ThemeModeType.values.length; i++)
                _buildThemeChip(
                  ThemeModeType.values[i], 
                  i == 0, 
                  i == ThemeModeType.values.length - 1
                ),
            ],
          ),
        ),
      );
    } else {
      // On desktop, show only current and expand on hover
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Current button always visible
            _buildThemeOption(widget.themeMode, isActive: true),
            
            // Additional options on hover - absolutely positioned
            if (_isHovered)
              Positioned(
                top: -15, // Higher to avoid gaps
                right: -5, // Small overlap
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    constraints: const BoxConstraints(maxWidth: 180),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // All options vertically as dropdown
                        for (ThemeModeType mode in ThemeModeType.values)
                          _buildDropdownOption(mode, isActive: widget.themeMode == mode),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }
}