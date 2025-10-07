# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

## [1.0.1] - 2025-10-07

### Added
- Remote configuration support with automatic detection
  - EnvConfig now auto-detects remote mode based on URL presence
  - Support for `--dart-define-from-file` with environment files
  - Firebase Storage integration for remote configuration
  - Automatic fallback to local configuration if remote fails
  - RemoteConfigService with caching and retry logic (1 hour cache, 3 retries)
- Comprehensive volunteering section with 9 experiences
  - Techstars Startup Weekend (2018)
  - SEGIB - Secretaría General Iberoamericana (2018-2019)
  - FLISoL co-organizer (2012-2013)
  - SG Virtual Conference speaker entries with specific talk details
  - DevFest Campeche organizer
  - Local universities mentor
  - Campeche Developer Community founder
- Detailed SG Virtual Conference presentations
  - 2020: "El secreto para ser un desarrollador Senior" with URL
  - 2017: "La verdad sobre los equipos de trabajo" with URL
- README_CONFIG.md with complete configuration guide
  - Multiple environment file examples (.env.production, .env.development, .env.staging)
  - Remote and local configuration instructions
  - Firebase Storage hosting examples
- CHANGELOG.md for tracking project changes

### Changed
- Simplified environment configuration (removed CONFIG_SOURCE requirement)
- Updated volunteering section in both Spanish and English configs
- Environment files now use web/.env structure
- Configuration system is now intelligent and auto-detects mode

### Fixed
- Menu active indicator jumping to start when scrolling to bottom on mobile
  - Added bottom-of-page detection (100px threshold)
  - Active indicator now stays on last section when at bottom
  - Improved scroll position tracking in website_screen.dart

## [1.0.0] - 2025-10-07

### Added
- Initial release of Flutter personal portfolio website
- Fully configurable via JSON files (Spanish and English)
- Dynamic language switching (Spanish default, English support)
- Theme switching (light/dark/auto) with smooth transitions
- SEO optimization with structured data and meta tags
- HTML minification achieving ~9.7% size reduction
- Firebase hosting deployment with automated build process
- Blog integration via Medium RSS feeds
- Responsive design with mobile-first approach
- Complete widget architecture:
  - HeroSection with animated introduction
  - AboutSection with personal information
  - ExperienceSection with timeline
  - SkillsSection (cleaned up, no unused code)
  - ProjectsSection for showcasing work
  - BlogSection with Medium integration
  - ContactSection with social links
  - Footer with configurable content
- Core services:
  - ConfigService for configuration management
  - LocalizationService for language handling
  - ThemeService for dynamic theming
  - PreferencesService for user preferences
  - BlogService for Medium RSS integration
  - EnvService for environment configuration
  - app_logger for centralized logging
- Makefile with essential commands (dev, build, deploy, clean, etc.)

### Changed
- Updated dependencies to Flutter 3.x compatible versions
- Optimized build process with separate deploy-only command
- Simplified architecture by removing unused multi-language HTML generation
- Updated Flutter commands to work with current versions

### Removed
- Unused dependencies: flutter_staggered_grid_view, cupertino_icons
- All Dart warnings and dead code eliminated
- Complex multi-language HTML generation system

### Fixed
- All Dart analysis warnings resolved
- Cleaned up unused variables, methods, and imports
- Optimized configuration structure (single SEO config file)

---

## Guidelines for Updating This Changelog

### Categories
- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** in case of vulnerabilities

### Version Format
- Use [Semantic Versioning](https://semver.org/): MAJOR.MINOR.PATCH
- MAJOR: Breaking changes
- MINOR: New features (backwards compatible)
- PATCH: Bug fixes (backwards compatible)

### Entry Format
```markdown
## [Version] - YYYY-MM-DD

### Category
- Brief description of change
  - Additional details if needed
  - Technical implementation notes
```

### Tips
- Keep entries concise but informative
- Link to issues/PRs when applicable
- Group related changes together
- Date format: YYYY-MM-DD (ISO 8601)
- Move unreleased items to version when releasing
