import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../utils/responsive_utils.dart';
import '../models/website_config.dart';

class LanguageSelector extends StatefulWidget {
  final Function()? onLanguageChanged;
  final String? tooltip;
  final MyWebsiteConfig? config;

  const LanguageSelector({super.key, this.onLanguageChanged, this.tooltip, this.config});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;
  String? _currentLocale;
  bool _isReady = false;

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
    
    _loadCurrentLocaleSync();
  }
  
  void _loadCurrentLocaleSync() {
    // Use first supported locale as default while loading
    _currentLocale = LocalizationService.supportedLocales.first;
    _isReady = true; // Ready immediately with cached flags
    
    // Async get actual current locale without blocking UI
    LocalizationService.currentLocale.then((locale) {
      if (mounted) {
        setState(() {
          _currentLocale = locale;
        });
      }
    });
  }
  

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onLanguageSelected(String locale, BuildContext buttonContext) async {
    if (locale != _currentLocale) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      await LocalizationService.setLocale(locale);
      
      setState(() {
        _currentLocale = locale;
      });
      
      if (widget.onLanguageChanged != null) {
        widget.onLanguageChanged!();
      }
    }
  }

  Color _getLanguageColor(String locale) {
    // Use same color logic as theme selector for consistency
    return Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? 
           Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
  }

  Future<String> _getCurrentCode() async {
    // Get language code from config
    return await LocalizationService.getLanguageCode(_currentLocale ?? LocalizationService.supportedLocales.first);
  }

  Future<String> _getCodeForLocale(String locale) async {
    // Return language code from config
    return await LocalizationService.getLanguageCode(locale);
  }
  
  List<PopupMenuItem<String>> _buildPopupMenuItems() {
    return LocalizationService.supportedLocales.map((locale) {
      return PopupMenuItem<String>(
        value: locale,
        child: SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _currentLocale == locale
                  ? _getLanguageColor(locale).withValues(alpha: 0.1)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: _getLanguageColor(locale).withValues(alpha: 0.15),
                  ),
                  child: FutureBuilder<String>(
                    future: _getCodeForLocale(locale),
                    builder: (context, snapshot) {
                      final code = snapshot.data ?? locale.toUpperCase();
                      return Text(
                        code,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getLanguageColor(locale),
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<String>(
                    future: LocalizationService.getLanguageNameForLocale(locale),
                    builder: (context, snapshot) {
                      final languageName = snapshot.data ?? locale;
                      return Text(
                        languageName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: _currentLocale == locale
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _currentLocale == locale
                              ? _getLanguageColor(locale)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                if (_currentLocale == locale) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    color: _getLanguageColor(locale),
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLanguageCode(String code, Color color, double fontSize) {
    return Text(
      code,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: color,
        fontSize: fontSize,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Don't show anything until emojis are fully loaded
    if (!_isReady) {
      return const SizedBox.shrink();
    }
    
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
            child: _HoverActivatedPopupMenuButton<String>(
              onSelected: (String locale) => _onLanguageSelected(locale, buttonContext),
              itemBuilder: (BuildContext context) => _buildPopupMenuItems(),
              offset: const Offset(0, 40),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).colorScheme.surface,
              shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.2),
              child: _LanguageSelectorButton(
                currentLocale: _currentLocale,
                pulseAnimation: _pulseAnimation,
                opacityAnimation: _opacityAnimation,
                getLanguageColor: _getLanguageColor,
                getCurrentCode: _getCurrentCode,
                buildLanguageCode: _buildLanguageCode,
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
        // Optimal width for mobile: now that switches are stacked vertically, they can be wider
        final optionCount = LocalizationService.supportedLocales.length;
        final baseWidth = 100.0; // Optimal width for 2 language options
        final availableWidth = constraints.maxWidth > 0 ? constraints.maxWidth : baseWidth;
        final switchWidth = (availableWidth * 0.95).clamp(85.0, baseWidth); // More generous now that we're vertical
        final optionWidth = (switchWidth - 4) / optionCount; // Account for padding
        
        return GestureDetector(
          onPanUpdate: (details) {
            // Calculate which option should be active based on drag position
            final localPosition = details.localPosition.dx;
            final optionIndex = (localPosition / optionWidth).clamp(0, optionCount - 1).round();
            
            if (optionIndex < LocalizationService.supportedLocales.length) {
              final targetLocale = LocalizationService.supportedLocales[optionIndex];
              if (targetLocale != _currentLocale) {
                _onLanguageSelected(targetLocale, context);
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
                  top: 2,
                  bottom: 2,
                  width: optionWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(19), // Adjusted for new height
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                // Options
                Row(
                  children: LocalizationService.supportedLocales.map((locale) {
                    final isActive = _currentLocale == locale;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onLanguageSelected(locale, context),
                        child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(19), // Adjusted for new height
                          ),
                          child: Center(
                            child: FutureBuilder<String>(
                              future: LocalizationService.getLanguageCode(locale),
                              builder: (context, snapshot) {
                                final code = snapshot.data ?? locale.toUpperCase();
                                return AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                    color: isActive 
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                  child: Text(code),
                                );
                              },
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
    final currentIndex = LocalizationService.supportedLocales.indexOf(_currentLocale ?? LocalizationService.supportedLocales.first);
    return 2.0 + (currentIndex * optionWidth);
  }

}

class _LanguageSelectorButton extends StatefulWidget {
  final String? currentLocale;
  final Animation<double> pulseAnimation;
  final Animation<double> opacityAnimation;
  final Color Function(String) getLanguageColor;
  final Future<String> Function() getCurrentCode;
  final Widget Function(String, Color, double) buildLanguageCode;

  const _LanguageSelectorButton({
    required this.currentLocale,
    required this.pulseAnimation,
    required this.opacityAnimation,
    required this.getLanguageColor,
    required this.getCurrentCode,
    required this.buildLanguageCode,
  });

  @override
  State<_LanguageSelectorButton> createState() => _LanguageSelectorButtonState();
}

class _LanguageSelectorButtonState extends State<_LanguageSelectorButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final locale = widget.currentLocale ?? 'default';
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isHovered 
            ? widget.getLanguageColor(locale).withValues(alpha: 0.2)
            : widget.getLanguageColor(locale).withValues(alpha: 0.1),
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
                    child: FutureBuilder<String>(
                      future: widget.getCurrentCode(),
                      builder: (context, snapshot) {
                        final code = snapshot.data ?? 'EN';
                        return AnimatedSwitcher(
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
                          child: widget.buildLanguageCode(
                            code,
                            widget.getLanguageColor(widget.currentLocale ?? 'default'),
                            12,
                          ),
                        );
                      },
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