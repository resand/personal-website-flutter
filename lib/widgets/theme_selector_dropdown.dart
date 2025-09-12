import 'package:flutter/material.dart';
import '../utils/theme_types.dart';
import '../models/website_config.dart';
import '../utils/responsive_utils.dart';

class ThemeSelectorDropdown extends StatefulWidget {
  final ThemeModeType themeMode;
  final Function(ThemeModeType) onThemeChanged;
  final Function(Offset?) onThemeToggle;
  final String? tooltip;
  final MyWebsiteConfig config;

  const ThemeSelectorDropdown({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onThemeToggle,
    required this.config,
    this.tooltip,
  });

  @override
  State<ThemeSelectorDropdown> createState() => _ThemeSelectorDropdownState();
}

class _ThemeSelectorDropdownState extends State<ThemeSelectorDropdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;

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

  void _onThemeSelected(ThemeModeType themeMode, BuildContext buttonContext) {
    if (themeMode != widget.themeMode) {
      // Gentle pulse animation for theme icons
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
        return Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
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

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    if (isMobile) {
      // Mobile: native switch style selector
      return _buildMobileSwitch(context);
    } else {
      // Desktop: PopupMenuButton original con hover
      return Builder(
        builder: (buttonContext) => Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: IntrinsicWidth(
            child: _HoverActivatedPopupMenuButton<ThemeModeType>(
              onSelected: (ThemeModeType mode) => _onThemeSelected(mode, buttonContext),
              itemBuilder: (BuildContext context) => [
                for (ThemeModeType mode in ThemeModeType.values)
                  PopupMenuItem<ThemeModeType>(
                    value: mode,
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: widget.themeMode == mode
                              ? _getThemeColor(mode).withValues(alpha: 0.1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: _getThemeColor(mode).withValues(alpha: 0.15),
                              ),
                              child: Icon(
                                _getThemeIcon(mode),
                                color: _getThemeColor(mode),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getThemeText(mode),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: widget.themeMode == mode
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: widget.themeMode == mode
                                      ? _getThemeColor(mode)
                                      : null,
                                ),
                              ),
                            ),
                            if (widget.themeMode == mode) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.check_circle,
                                color: _getThemeColor(mode),
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
              offset: const Offset(0, 40),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).colorScheme.surface,
              shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.2),
              child: _ThemeSelectorButton(
                themeMode: widget.themeMode,
                pulseAnimation: _pulseAnimation,
                opacityAnimation: _opacityAnimation,
                getThemeIcon: _getThemeIcon,
                getThemeColor: _getThemeColor,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildMobileSwitch(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Optimal width for mobile: now that switches are stacked vertically, use same width as language selector
        final optionCount = ThemeModeType.values.length;
        final baseWidth = 100.0; // Same width as language selector for visual consistency
        final availableWidth = constraints.maxWidth > 0 ? constraints.maxWidth : baseWidth;
        final switchWidth = (availableWidth * 0.95).clamp(85.0, baseWidth); // Consistent with language selector
        final optionWidth = (switchWidth - 6) / optionCount; // Slightly more padding
        
        return GestureDetector(
          onPanUpdate: (details) {
            // Calculate which option should be active based on drag position
            final localPosition = details.localPosition.dx;
            final optionIndex = (localPosition / optionWidth).clamp(0, optionCount - 1).round();
            
            if (optionIndex < ThemeModeType.values.length) {
              final targetMode = ThemeModeType.values[optionIndex];
              if (targetMode != widget.themeMode) {
                _onThemeSelected(targetMode, context);
              }
            }
          },
          child: Container(
            width: switchWidth,
            height: 42, // Increased from 36 for better visual presence
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(21), // Slightly increased for new height
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Sliding background indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutCubic,
                  left: _getSwitchPosition(optionWidth),
                  top: 3,
                  bottom: 3,
                  width: optionWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getThemeColor(widget.themeMode).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(19), // Adjusted for new height
                      border: Border.all(
                        color: _getThemeColor(widget.themeMode).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                // Options
                Row(
                  children: ThemeModeType.values.map((mode) {
                    final isActive = widget.themeMode == mode;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onThemeSelected(mode, context),
                        child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(19), // Adjusted for new height
                          ),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                _getThemeIcon(mode),
                                size: 16,
                                color: isActive 
                                  ? _getThemeColor(mode)
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _getSwitchPosition(double optionWidth) {
    final currentIndex = ThemeModeType.values.indexOf(widget.themeMode);
    return 3.0 + (currentIndex * optionWidth);
  }
}

class _ThemeSelectorButton extends StatefulWidget {
  final ThemeModeType themeMode;
  final Animation<double> pulseAnimation;
  final Animation<double> opacityAnimation;
  final IconData Function(ThemeModeType) getThemeIcon;
  final Color Function(ThemeModeType) getThemeColor;

  const _ThemeSelectorButton({
    required this.themeMode,
    required this.pulseAnimation,
    required this.opacityAnimation,
    required this.getThemeIcon,
    required this.getThemeColor,
  });

  @override
  State<_ThemeSelectorButton> createState() => _ThemeSelectorButtonState();
}

class _ThemeSelectorButtonState extends State<_ThemeSelectorButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isHovered 
            ? widget.getThemeColor(widget.themeMode).withValues(alpha: 0.2)
            : widget.getThemeColor(widget.themeMode).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.pulseAnimation, widget.opacityAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: widget.pulseAnimation.value,
              child: Opacity(
                opacity: widget.opacityAnimation.value,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        widget.getThemeIcon(widget.themeMode),
                        key: ValueKey(widget.themeMode),
                        size: 20,
                        color: isHovered 
                          ? widget.getThemeColor(widget.themeMode)
                          : widget.getThemeColor(widget.themeMode).withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HoverActivatedPopupMenuButton<T> extends StatefulWidget {
  final PopupMenuItemSelected<T> onSelected;
  final PopupMenuItemBuilder<T> itemBuilder;
  final Offset offset;
  final double elevation;
  final ShapeBorder shape;
  final Color color;
  final Color shadowColor;
  final Widget child;

  const _HoverActivatedPopupMenuButton({
    required this.onSelected,
    required this.itemBuilder,
    required this.offset,
    required this.elevation,
    required this.shape,
    required this.color,
    required this.shadowColor,
    required this.child,
  });

  @override
  State<_HoverActivatedPopupMenuButton<T>> createState() => _HoverActivatedPopupMenuButtonState<T>();
}

class _HoverActivatedPopupMenuButtonState<T> extends State<_HoverActivatedPopupMenuButton<T>> {
  final GlobalKey _popupKey = GlobalKey<PopupMenuButtonState>();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        // Activar el PopupMenuButton con hover
        final dynamic popupButton = _popupKey.currentState;
        if (popupButton != null) {
          popupButton.showButtonMenu();
        }
      },
      child: PopupMenuButton<T>(
        key: _popupKey,
        onSelected: widget.onSelected,
        itemBuilder: widget.itemBuilder,
        offset: widget.offset,
        elevation: widget.elevation,
        shape: widget.shape,
        color: widget.color,
        shadowColor: widget.shadowColor,
        child: widget.child,
      ),
    );
  }
}