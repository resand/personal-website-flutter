# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

## [1.5.0] - 2026-04-25

### Added
- Mobile-first responsive system in `ResponsiveUtils` with `sectionPadding`, `valueFor`, `isDesktop`, and shared section width constants.
- Reusable `SectionHeader` widget consumed by every page section.
- `UrlHelper` utility centralizing `launchUrl` calls with `SnackBar` error feedback.
- `<noscript>` fallback in `web/index.html` with author name, description and email link.
- Dynamic `<html lang>` synchronization on locale change via `package:web`.
- `Semantics` labels on hero avatar, social icon buttons and project images.
- `loadingBuilder` skeleton on project images and reserved height in blog loading state to prevent CLS.
- HTML template placeholders for `THEME_COLOR`, `OG_IMAGE_URL` and `AUTHOR_EMAIL`, processed in `scripts/process-html.js`.
- `retry_button` and `error_loading_config` strings in both locales and `UITexts` model.
- Local-only documentation files added to `.gitignore` (`CLAUDE.md`, `GITHUB_PROFILE_README.md`, `.claude/`).

### Changed
- Bumped `font_awesome_flutter` to `^11.0.0` (introduces `FaIconData`) and `google_fonts` to `^8.0.2`.
- Mobile-first padding applied to about, experience, skills, projects, contact, volunteering, education, certifications, blog, hero and footer sections.
- Hero avatar size now scales responsively (200/240/300) with consistent radius and `Semantics` wrapper; nameplate gains `softWrap`.
- Volunteering section now respects `Theme.textTheme` instead of hard-coded 9–12 px font sizes for legibility on mobile.
- Education section reflows to vertical layout from tablet down and adds `softWrap` on degree/field text.
- Scroll listener throttled with an 80 ms `Timer` debounce to avoid jank on `_updateCurrentSection`.
- Hover-activated popup menus (theme + language selectors) now wait 180 ms before opening and cancel on `onExit`.
- Loader flow: `_isLoading` stays true until critical above-the-fold images precache (avatar + logos) with a 1.5 s timeout, keeping the Lottie visible briefly without blocking on every project image.
- `index.html`: removed redundant `<meta name="viewport">` (Flutter Web injects its own) and replaced same-URL `hreflang` block with a proper `canonical` + `x-default` setup.
- Deduplicated `_HoverActivatedPopupMenuButton` between language and theme selectors.

### Fixed
- 404 errors on `web/images/logos/*.png` during precache: `_imageProviderFor` now picks `NetworkImage` for relative web-root paths instead of treating them as Flutter assets.
- Image precache no longer uses `http.get` (which never populated Flutter's image cache); replaced with `precacheImage`.
- Removed the artificial 500 ms delay and the `Future.wait` over every project image, eliminating multi-second startup blocking.
- `AnimatedBuilder` no longer wraps the whole `MaterialApp`, preventing full-app rebuilds on every theme animation tick.
- Hard-coded loader/error strings replaced with config-driven values.
- Type errors (`FaIconData` vs `IconData`) after the font_awesome_flutter major bump in hero, footer and blog sections.
- Removed orphan widget files: `language_selector_hover.dart`, `theme_selector_hover.dart`, `scroll_animated_section.dart`, `theme_transition_overlay.dart`.

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
