# Personal Website - Flutter Web 🚀

A modern, fully configurable and multilingual personal website built with Flutter Web to showcase experience, projects, education, certifications, and blog articles professionally.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Web](https://img.shields.io/badge/Web-4285F4?style=for-the-badge&logo=google-chrome&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

## 📋 Table of Contents

- [✨ Features](#-features)
- [🛠️ Technologies and Dependencies](#️-technologies-and-dependencies) 
- [🚀 Quick Start](#-quick-start)
- [⚙️ Configuration](#️-configuration)
- [🔧 Environment Variables](#-environment-variables-environment)
- [🚀 Deployment](#-deployment)
- [⚡ Useful Commands](#-useful-commands)
- [🛠️ Project Structure](#️-project-structure)
- [🎨 Advanced Features](#-advanced-features)
- [🔧 Advanced Customization](#-advanced-customization)
- [📝 Blog Integration](#-blog-integration)
- [🔧 Troubleshooting](#-troubleshooting)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [🆘 Support](#-support)

## ✨ Features

- 🎨 **Fully configurable** via JSON files
- 🌍 **Dual-language support** with dynamic selection (default language + English)
- 📱 **Responsive design** optimized for mobile, tablet, and desktop
- 📝 **Blog integration** with Medium and Dev.to RSS support
- 🚀 **Firebase Hosting optimized** with automated deployment
- 🎯 **10 customizable sections**: Hero, Projects, Skills, Experience, Education, Certifications, About, Blog, Volunteering, Contact
- 🌙 **Theme selector** (Light/Dark/Auto) with smooth transitions
- 🎓 **Education section** with complete academic background
- 🏆 **Certifications section** with adaptive grid layout
- ⚡ **Performance optimized** with smooth animations
- 🔧 **Modular architecture** easy to customize and extend
- 📧 **Email integration** for direct contact

## 🛠️ Technologies and Dependencies

### Main Stack  
- **Flutter Web** (3.35.3+) - Cross-platform framework
- **Dart SDK** (3.9.2+) - Programming language

### Core Dependencies
- **http** (^1.1.0) - HTTP client for APIs and RSS
- **url_launcher** (^6.1.12) - Open external URLs
- **google_fonts** (^6.1.0) - Google typography fonts
- **font_awesome_flutter** (^10.6.0) - Font Awesome icons
- **lottie** (^3.1.2) - Lottie animations for loaders
- **shared_preferences** (^2.3.2) - Local persistence of configurations
- **logger** (^2.0.2+1) - Logging system

### Development Tools
- **flutter_lints** (^6.0.0) - Recommended linting rules
- **flutter_test** - Integrated testing framework

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** (3.35.3 or higher)
- **Dart SDK** (3.9.2 or higher) 
- **Firebase CLI** (optional, for deployment)
- **Chrome/Edge** (for web development)
- **Node.js** (for Firebase CLI)

### Installation

**Quick Start (Recommended)**
```bash
# Clone and setup everything automatically
git clone https://github.com/resand/personal-website-flutter.git
cd personal-website-flutter
make setup
```

**Development Commands**
```bash
# Development with hot reload
make dev

# Run web app in Chrome  
make web

# Production build locally
make web-release

# Build for production
make build

# Code analysis
make analyze

# Clean project
make clean
```

**Deployment**
```bash
# Option 1: Complete deployment (clean + build + deploy)
make deploy

# Option 2: Optimized workflow (build once, deploy without rebuilding)
make build        # Build for production
make deploy-only  # Deploy without rebuilding

# Check status
make status

# Open website
make open
```

## ⚙️ Configuration

The website supports **dual-language configuration** with two JSON files:
- `assets/config/website_config_default.json` (Your default language - Spanish in this example, but configure for your preferred language)
- `assets/config/website_config_english.json` (English - secondary language for switching)

**After running `make setup`, edit your personal information in these files:**

### Personal Information
```json
{
  "personal_info": {
    "name": "René Sandoval",
    "title": "Ingeniero de Software | GDG Lead Organizer",
    "subtitle": "13+ años diseñando y desarrollando soluciones web, backend y móviles",
    "bio": "Your complete biography here...",
    "short_bio": "Short biography for hero section...",
    "fun_fact": "Ex-Carpintero → Programador",
    "email": "your.email@example.com",
    "location": "Your City, Country",
    "avatar_url": "https://avatars.githubusercontent.com/u/5307015?v=4",
    "logo_light_url": "images/logos/logo-light.png",
    "logo_dark_url": "images/logos/logo_dark.png",
    "years_of_experience": "13+"
  },
  "language_info": {
    "code": "ES",
    "name": "Español"
  }
}
```

### Social Links (Array Format)
```json
{
  "social_links": [
    {
      "platform": "linkedin",
      "url": "https://www.linkedin.com/in/your-profile"
    },
    {
      "platform": "github", 
      "url": "https://github.com/your-username"
    },
    {
      "platform": "medium",
      "url": "https://medium.com/@your-username"
    },
    {
      "platform": "x",
      "url": "https://x.com/your-username"
    },
    {
      "platform": "instagram",
      "url": "https://instagram.com/your-username"
    }
  ]
}
```

### Blog Integration (Medium & Dev.to)
```json
{
  "blog_config": {
    "show_latest_posts": true,
    "max_posts_to_show": 6,
    "sources": [
      {
        "name": "Medium",
        "username": "resand",
        "rss_url": "https://medium.com/feed/@resand",
        "enabled": true
      }
    ],
    "section_title": "Últimas Publicaciones",
    "section_description": "Artículos y reflexiones sobre arquitectura, desarrollo móvil, web y mejores prácticas",
    "error_title": "No se pudieron cargar los artículos",
    "error_message": "Puedes visitar mi perfil de Medium directamente",
    "empty_message": "No hay artículos disponibles",
    "view_all_text": "Ver todos los artículos en Medium"
  }
}
```

### Professional Experience
```json
{
  "experience": [
    {
      "company": "Fraternitas",
      "position": "iOS Developer",
      "duration": "Julio 2023 - Noviembre 2024",
      "location": "Texas, Estados Unidos (Remoto)",
      "description": "Desarrollo y refactorización de aplicaciones de remesas y pagos de servicios desde USA hacia LATAM.",
      "technologies": ["iOS", "Swift", "UIKit", "VIPER", "JWE", "Flutter"],
      "highlights": [
        "Migré aplicación completa de Storyboards a vistas programáticas con UIKit",
        "Implementé patrón VIPER y principios DRY para arquitectura escalable",
        "Integré seguridad avanzada con JWE en servicios críticos"
      ]
    },
    {
      "company": "Finerio Connect",
      "position": "Mobile Tech Lead",
      "duration": "Octubre 2021 - Marzo 2023",
      "location": "Ciudad de México, México (Remoto)",
      "description": "Liderazgo técnico de equipos móviles y desarrollo de SDKs para Open Banking.",
      "technologies": ["iOS", "Android", "Swift", "Open Banking", "UI/UX"],
      "highlights": [
        "Dirigí equipos de desarrollo iOS y Android con metodologías ágiles",
        "Diseñé features con fuerte enfoque en principios de UI/UX"
      ]
    }
  ]
}
```

### Technical Skills
```json
{
  "skills": {
    "categories": [
      {
        "id": "mobile",
        "title": "Móvil",
        "icon": "flutter_dash",
        "skills": [
          { "name": "iOS", "level": "Avanzado" },
          { "name": "Swift", "level": "Avanzado" },
          { "name": "SwiftUI", "level": "Experto" },
          { "name": "Flutter", "level": "Avanzado" }
        ]
      },
      {
        "id": "architectures",
        "title": "Arquitecturas",
        "icon": "account_tree",
        "skills": [
          { "name": "VIPER", "level": "Experto" },
          { "name": "MVVM", "level": "Experto" },
          { "name": "Clean Architecture", "level": "Avanzado" }
        ]
      },
      {
        "id": "backend",
        "title": "Backend",
        "icon": "cloud_queue",
        "skills": [
          { "name": "C#", "level": "Avanzado" },
          { "name": ".NET", "level": "Avanzado" },
          { "name": "API REST", "level": "Experto" }
        ]
      }
    ]
  }
}
```

### 🎓 Education
```json
{
  "education": [
    {
      "institution": "Universidad Da Vinci",
      "degree": "Maestría en Sistemas Computacionales",
      "field": "Ingeniería de Sistemas",
      "duration": "Abril 2020 - Diciembre 2021"
    },
    {
      "institution": "Instituto Tecnológico de Campeche",
      "degree": "Licenciatura en Ciencias de la Computación",
      "field": "Ingeniería de Software",
      "duration": "2009 - 2014"
    }
  ]
}
```

### 🏆 Certifications
```json
{
  "certifications": [
    "CCNA: Introduction to Networks",
    "CCNA: Switching, Routing, and Wireless Essentials",
    "Scrum Foundation Professional Certification - SFPC",
    "edX Honor Code Certificate for the Mobile Devices for Territory Management course"
  ]
}
```

### Featured Projects
```json
{
  "projects": [
    {
      "name": "Plataforma de Remesas Escalable",
      "description": "Aplicación móvil para envío de remesas y pagos de servicios desde USA hacia LATAM, con arquitectura VIPER y seguridad avanzada.",
      "technologies": ["Swift", "UIKit", "VIPER", "JWE"],
      "github_url": null,
      "live_url": null,
      "image_url": null,
      "featured": true
    },
    {
      "name": "SDK Open Banking",
      "description": "Desarrollo de SDKs para Open Banking y PFM con integración multiplataforma y enfoque en experiencia de usuario.",
      "technologies": ["Swift", "Android", "Open Banking", "SDK Development"],
      "github_url": null,
      "live_url": null,
      "image_url": null,
      "featured": true
    }
  ]
}
```

### Volunteering
```json
{
  "volunteering": [
    {
      "organization": "Google Developer Group (GDG)",
      "role": "Lead Organizer",
      "duration": "2019 - Presente",
      "description": "Liderazgo y organización de eventos tecnológicos para la comunidad de desarrolladores.",
      "impact": "He organizado muchos eventos técnicos y talleres para la comunidad local, impactando a cientos de desarrolladores",
      "website": "https://developers.google.com/community/gdg"
    }
  ]
}
```

### 🎨 Themes and Customization
```json
{
  "theme": {
    "default_mode": "auto",
    "font_family": "Poppins",
    "enable_animations": true,
    "light_colors": {
      "primary": "#374151",
      "secondary": "#6B7280", 
      "accent": "#10B981",
      "background": "#F9FAFB",
      "surface": "#FFFFFF"
    },
    "dark_colors": {
      "primary": "#4B5563",
      "secondary": "#6B7280",
      "accent": "#10B981", 
      "background": "#000000",
      "surface": "#111111"
    }
  }
}
```

### 🎯 Section Control
```json
{
  "layout": {
    "show_hero_section": true,
    "show_about_section": true,
    "show_experience_section": true,
    "show_skills_section": true,
    "show_projects_section": true,
    "show_volunteering_section": true,
    "show_education_section": true,
    "show_certifications_section": true,
    "show_blog_section": true,
    "show_contact_section": true,
    "enable_dark_mode": true,
    "enable_animations": true,
    "section_order": [
      "hero",
      "projects",
      "skills",
      "experience",
      "education",
      "certifications",
      "about",
      "blog",
      "volunteering",
      "contact"
    ]
  }
}
```

## 🔧 Environment Variables & Configuration

### 🎬 Lottie Loader Configuration

The project uses a **hardcoded Lottie loader** system for reliable performance:

#### Implementation
- **Loader Type**: Lottie animation
- **Lottie File**: `assets/lotties/loader.json`
- **Size Configuration**: Configurable via environment variables

#### Environment Setup

Create `web/.env` file:
```env
# Loader height/size
LOADER_HEIGHT=250
```

#### 🎨 Lottie Assets

Available Lottie animations in `assets/lotties/`:
- **`loader.json`**: Main loader with dynamic color support
- **`loader_dino.json`**: Alternative dinosaur loader

#### 🔄 How It Works

1. **Direct Loading**: Loads `assets/lotties/loader.json`
2. **Dynamic Sizing**: Configurable height via `web/.env`
3. **Theme Adaptive**: Automatic color adaptation for light/dark themes
4. **Fallback**: Uses CircularProgressIndicator if loading fails

### 🎯 SEO Configuration

#### SEO Config Files
- `assets/config/seo_config.json` - SEO metadata for your default language

#### Google Analytics Integration
```json
{
  "analytics": {
    "google_analytics_id": "G-26TNM1F3EV",
    "gtag_config": {
      "page_title": "René Sandoval - Software Engineer",
      "content_group1": "Personal Website", 
      "language": "en",
      "country": "MX"
    }
  }
}
```

#### HTML Template Processing
- Uses placeholder system in `web/index.html`
- Processed by `scripts/process-html.js` during build
- Generates SEO-optimized HTML automatically

#### ⚙️ Environment Variables (.env)

**Configuration:**
```env
# Loader height/size
LOADER_HEIGHT=250
```

## 🚀 Deployment

### Firebase Hosting (Recommended)

#### Initial Setup (One Time Only)

1. **Install Firebase CLI:**
```bash
npm install -g firebase-tools
```

2. **Login to Firebase:**
```bash
firebase login
```

3. **Create a project in Firebase Console:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or select existing one
   - Enable Firebase Hosting in the project

4. **Configure your local project:**
```bash
# List your available projects
firebase projects:list

# Edit .firebaserc with your project ID
{
  "projects": {
    "default": "your-project-id"
  }
}
```

5. **Verify configuration:**
```bash
# Select your project
firebase use your-project-id

# Verify hosting sites
firebase hosting:sites:list
```

#### Automated Deployment

**Option 1: Automated Script (Recommended)**
```bash
scripts/deploy.sh
```

**Option 2: Manual Commands**
```bash
# 1. Clean and prepare
flutter clean
flutter pub get

# 2. Build for production
flutter build web --release

# 3. Deploy to Firebase
firebase deploy --only hosting
```

The `scripts/deploy.sh` script includes:
- ✅ Flutter and Firebase CLI verification
- 🧹 Project cleanup (`flutter clean`)
- 📦 Dependencies installation (`flutter pub get`)
- 🔨 Optimized production build (`flutter build web --release`)
- 🚀 Firebase Hosting deployment (`firebase deploy --only hosting`)
- ✔️ Success verification

#### Example URLs
- **Console**: `https://console.firebase.google.com/project/your-project-id`
- **Website**: `https://your-project-id.web.app`
- **Custom domain**: Configurable in Firebase Console

### Other Services

Compatible with:
- **Netlify**: Upload `build/web` after `flutter build web --release`
- **GitHub Pages**: Configure Actions for automated deployment  
- **Vercel**: Direct deploy from `build/web`

## ⚡ Useful Commands

### Development
```bash
# Development server
flutter run -d chrome

# With hot reload enabled
flutter run -d chrome --hot

# Debug mode with detailed information
flutter run -d chrome --verbose
```

### Build and Testing
```bash
# Code analysis
flutter analyze

# Build for web (development)
flutter build web

# Build for web (production)
flutter build web --release

# Build with experimental WASM mode
flutter build web --wasm
```

### Maintenance
```bash
# Clean complete project
flutter clean

# Update dependencies
flutter pub get

# Check outdated dependencies
flutter pub outdated

# Upgrade dependencies (careful)
flutter pub upgrade

# View Flutter information
flutter doctor

# View available devices
flutter devices
```

### Firebase
```bash
# View projects
firebase projects:list

# Change active project
firebase use project-id

# View hosting sites
firebase hosting:sites:list

# Deploy only (without build)
firebase deploy --only hosting

# View hosting channels
firebase hosting:channel:list

# Deploy to specific channel
firebase hosting:channel:deploy preview-name
```

## 🛠️ Project Structure

```
lib/
├── main.dart                        # Application entry point
├── models/                          # Data models
│   ├── blog_post.dart               # Blog post model for RSS integration
│   └── website_config.dart          # Main configuration and models
├── services/                        # Application services
│   ├── config_service.dart          # Configuration loading wrapper
│   ├── localization_service.dart    # Multi-language localization service
│   ├── theme_service.dart           # Dynamic theme generation
│   ├── blog_service.dart            # Blog API integration (Medium RSS)
│   ├── env_service.dart             # Environment variables service
│   ├── preferences_service.dart     # User preferences management
│   └── meta_service.dart            # Dynamic meta tags service
├── screens/
│   └── website_screen.dart          # Main website screen
├── widgets/                         # Modular UI components
│   ├── navigation_bar.dart          # Responsive navigation bar
│   ├── hero_section.dart            # Introduction section
│   ├── about_section.dart           # About me section
│   ├── experience_section.dart      # Professional experience
│   ├── skills_section.dart          # Technical skills
│   ├── projects_section.dart        # Featured projects
│   ├── volunteering_section.dart    # Volunteer work
│   ├── education_section.dart       # Academic background
│   ├── certifications_section.dart  # Technical certifications
│   ├── blog_section.dart            # Latest blog articles
│   ├── contact_section.dart         # Contact information
│   ├── footer.dart                  # Page footer
│   ├── scroll_animated_section.dart # Scroll animations
│   ├── theme_selector_dropdown.dart # Theme selector (desktop)
│   ├── theme_selector_hover.dart    # Theme selector with hover effects
│   ├── theme_transition_overlay.dart# Theme switching animation
│   ├── language_selector.dart       # Language selector (mobile)
│   └── language_selector_hover.dart # Language selector with hover effects
└── utils/                           # Utility classes
    ├── responsive_utils.dart        # Responsive design utilities
    ├── elevation_utils.dart         # Material elevation and shadow utilities
    ├── app_logger.dart              # Centralized logging system
    └── theme_types.dart             # Custom theme type definitions

assets/
├── config/
│   ├── website_config_default.json  # Default language configuration
│   ├── website_config_english.json  # English configuration
│   └── seo_config.json              # SEO metadata and structured data
└── lotties/                         # Lottie animations
    ├── loader.json                  # Main loader animation
    └── loader_dino.json             # Alternative dinosaur loader

web/
├── .env                            # Environment variables (optional)
├── images/                         # Static images served directly
│   └── logos/                      # Site logos (light/dark versions)
│       ├── logo-light.png          # Light theme logo
│       └── logo_dark.png           # Dark theme logo
├── icons/                          # PWA icons and favicon
├── js/                             # JavaScript files
├── index.html                      # HTML template with SEO placeholders
├── robots.txt                      # Search engine crawler instructions
├── sitemap.xml                     # Site structure for SEO
└── ...                             # Other web assets

scripts/
├── deploy.sh                       # Automated deployment script
└── process-html.js                 # HTML processing and minification

Other Files:
├── Makefile                        # Development and deployment commands
├── CLAUDE.md                       # Development guidelines for AI assistance
├── firebase.json                   # Firebase hosting configuration
├── .firebaserc                     # Firebase project configuration
├── package.json                    # Node.js dependencies for HTML processing
└── pubspec.yaml                    # Flutter dependencies
```


## 🎨 Advanced Features

### 🌍 Dual-language Support
- **Dynamic selector**: Switch between your default language and English without reloading
- **Separate configuration**: Two independent JSON files (default + English)
- **Complete localization**: All texts, labels and content
- **Flexible default**: Default language can be any language you choose (Spanish, Portuguese, Ukrainian, Russian, etc.)
- **Persistence**: Remembers selected language

### 🌙 Theme System
- **3 available modes**: Light, Dark, Auto (system)
- **Smooth transitions**: Fluid animations between themes
- **Customizable colors**: Complete palette configurable via JSON
- **Responsive**: Adapted for all screen sizes

### 📱 Responsive Design
- **Mobile**: Optimized navigation with hamburger menu
- **Tablet**: Hybrid layout with adapted navigation
- **Desktop**: Full navigation in top bar
- **Animations**: Scroll effects and transitions

### 🎯 Smart Navigation
- **Smooth scroll**: Automatic navigation between sections
- **Active indicator**: Highlights current section
- **Keyboard**: Support for keyboard navigation
- **Deep anchors**: URLs that point to specific sections

## 🔧 Advanced Customization

### Granular Section Control
Each section can be enabled/disabled individually:

```json
{
  "layout": {
    "show_hero_section": true,
    "show_about_section": true,
    "show_experience_section": true,
    "show_skills_section": true,
    "show_projects_section": true,
    "show_volunteering_section": true,
    "show_education_section": true,      
    "show_certifications_section": true,
    "show_blog_section": true,
    "show_contact_section": true
  }
}
```

### Customizable Order
You can change the order of sections:

```json
{
  "section_order": [
    "hero",      // Always first
    "projects",  // Highlight your work
    "skills",    // Show your abilities
    "experience",// Your trajectory
    "education", // Your education
    "certifications", // Your certifications
    "about",     // Your personal story
    "blog",      // Your publications
    "volunteering", // Your social impact
    "contact"    // Always last
  ]
}
```

## 📝 Blog Integration

### Supported Platforms
The website supports multiple blog platforms:

**Medium**
- RSS URL: `https://medium.com/feed/@your-username`
- Simple configuration with username only

**Dev.to**  
- RSS URL: `https://dev.to/feed/your-username`
- Enable by setting `"enabled": true` in sources

**Multiple Sources**
- Support for multiple blog platforms simultaneously
- Configurable priority and limits per source
- Smart fallback when sources fail
- Customizable error messages

### Configuration Features
- **Smart fallback**: Shows alternative content if RSS fails
- **Configurable limit**: Control how many articles to show
- **Custom texts**: All messages and labels are configurable
- **Extensible**: Easily add other RSS-compatible platforms

## 🔧 Troubleshooting

### Common Problems

#### Build Errors
```bash
# Error: Could not resolve Flutter SDK path
flutter doctor  # Verify installation

# Error: Outdated dependencies
flutter clean
flutter pub get

# Error: Build issues - use different optimization
flutter build web --release
# or for WebAssembly (experimental)
flutter build web --wasm
```

#### Environment Issues
```bash
# .env file not found (normal)
cp .env.example web/.env

# Permission error in scripts/deploy.sh
chmod +x scripts/deploy.sh

# Firebase project not found
firebase projects:list
firebase use your-project-id
```

#### Development Issues
```bash
# Hot reload doesn't work
flutter run -d chrome --hot

# Port in use - specify custom port
flutter run -d chrome --web-hostname localhost --web-port 8080

# Cache issues
flutter clean
flutter pub get
flutter pub deps
```

#### Performance Issues
```bash
# Slow build - use profile mode
flutter run -d chrome --profile

# Production build
flutter build web --release

# WebAssembly compilation (experimental)
flutter build web --wasm
```

### 📋 Pre-Deploy Checklist

Before deploying, verify:

- ✅ `flutter analyze` passes without errors
- ✅ Environment variables configured (if using `.env`)
- ✅ URLs in configuration are accessible
- ✅ Images are in `web/images/` and assets in `assets/` folders
- ✅ Firebase project configured correctly
- ✅ `build/web` is generated without errors

## 🤝 Contributing

1. **Fork** the project
2. **Create** a feature branch (`git checkout -b feature/new-feature`)
3. **Commit** changes (`git commit -am 'Add new feature'`)
4. **Push** to the branch (`git push origin feature/new-feature`)
5. **Open** a Pull Request

### Guidelines

- Follow existing code conventions
- Add tests for new features
- Update documentation when necessary
- Use descriptive commits in English

## 📄 License

This project is under the MIT License. See [LICENSE](LICENSE) for details.

## 🆘 Support

- 📖 Complete documentation in the README
- 🐛 Report bugs in [Issues](https://github.com/resand/personal-website-flutter/issues)
- 💡 Request features with the `enhancement` tag

---

<p align="center">
  Made with ❤️ with Flutter by <a href="https://github.com/resand">René</a>
</p>