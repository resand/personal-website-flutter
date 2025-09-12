import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../utils/responsive_utils.dart';

class LanguageSelectorHover extends StatefulWidget {
  final Function()? onLanguageChanged;
  final String? tooltip;

  const LanguageSelectorHover({super.key, this.onLanguageChanged, this.tooltip});

  @override
  State<LanguageSelectorHover> createState() => _LanguageSelectorHoverState();
}

class _LanguageSelectorHoverState extends State<LanguageSelectorHover>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;
  String? _currentLocale;
  bool _isHovered = false;
  List<String>? _supportedLocales;

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
    
    _loadData();
  }
  
  Future<void> _loadData() async {
    final locale = await LocalizationService.currentLocale;
    final locales = LocalizationService.supportedLocales;
    if (mounted) {
      setState(() {
        _currentLocale = locale;
        _supportedLocales = locales;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onLanguageSelected(String locale) async {
    if (locale != _currentLocale) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      setState(() {
        _currentLocale = locale;
      });
      
      await LocalizationService.setLocale(locale);
      
      if (widget.onLanguageChanged != null) {
        widget.onLanguageChanged!();
      }
    }
  }

  Color _getLanguageColor(String locale) {
    switch (locale) {
      case 'default':
        return Theme.of(context).colorScheme.primary;
      case 'english':
        return Theme.of(context).colorScheme.secondary;
      default:
        return Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? 
               Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    }
  }

  Widget _buildDropdownOption(String locale, {bool isActive = false}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onLanguageSelected(locale),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isActive
                ? _getLanguageColor(locale).withValues(alpha: 0.1)
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: _getLanguageColor(locale).withValues(alpha: 0.15),
                ),
                child: FutureBuilder<String>(
                  future: LocalizationService.getLanguageCode(locale),
                  builder: (context, snapshot) {
                    final code = snapshot.data ?? locale.toUpperCase();
                    return Text(
                      code,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getLanguageColor(locale),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FutureBuilder<String>(
                  future: LocalizationService.getLanguageName(locale),
                  builder: (context, snapshot) => Text(
                    snapshot.data ?? locale.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? _getLanguageColor(locale) : null,
                    ),
                  ),
                ),
              ),
              if (isActive) ...[
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
  }

  Widget _buildLanguageOption(String locale, {bool isActive = false, bool isVisible = true}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isVisible ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _onLanguageSelected(locale),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive 
                  ? _getLanguageColor(locale).withValues(alpha: 0.2)
                  : _getLanguageColor(locale).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: isActive 
                  ? Border.all(color: _getLanguageColor(locale).withValues(alpha: 0.3), width: 1)
                  : null,
              ),
              child: AnimatedBuilder(
                animation: Listenable.merge([_pulseAnimation, _opacityAnimation]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: isActive ? _pulseAnimation.value : 1.0,
                    child: Opacity(
                      opacity: isActive ? _opacityAnimation.value : 1.0,
                      child: FutureBuilder<String>(
                        future: LocalizationService.getLanguageCode(locale),
                        builder: (context, snapshot) {
                          final code = snapshot.data ?? locale.toUpperCase();
                          return Text(
                            code,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getLanguageColor(locale),
                            ),
                          );
                        },
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
    if (_supportedLocales == null || _currentLocale == null) {
      // Show empty container while loading - no loader needed for instant UX
      return const SizedBox.shrink();
    }

    final isMobile = ResponsiveUtils.isMobile(context);

    if (isMobile) {
      // On mobile, show all options always visible in compact layout
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (String locale in _supportedLocales!)
              _buildLanguageOption(locale, isActive: _currentLocale == locale),
          ],
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
            // Current flag always visible
            _buildLanguageOption(_currentLocale!, isActive: true),
            
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
                    constraints: const BoxConstraints(maxWidth: 160),
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
                        for (String locale in _supportedLocales!)
                          _buildDropdownOption(locale, isActive: _currentLocale == locale),
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