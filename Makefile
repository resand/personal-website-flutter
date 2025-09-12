# ===============================================
# 🚀 Personal Website - Flutter Web Makefile
# ===============================================
# This Makefile guides you step by step to configure and deploy your personal website.

.PHONY: help setup check-deps install-deps verify setup-firebase configure-env \
        web dev web-release build analyze clean deploy deploy-only deploy-check status logs open \
        setup-complete

# Colors for output (disable if your terminal doesn't support them)
ifdef NO_COLOR
CYAN := 
GREEN := 
YELLOW := 
RED := 
BOLD := 
RESET := 
else
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
BOLD := \033[1m
RESET := \033[0m
endif

# Variables
PROJECT_NAME := personal-website-flutter
FIREBASE_PROJECT_ID := personal-website-resand

# ===============================================
# 📋 HELP - Shows all available commands
# ===============================================
help:
	@echo "$(BOLD)🚀 Personal Website - Flutter Web$(RESET)"
	@echo ""
	@echo "$(CYAN)$(BOLD)INITIAL SETUP (run once):$(RESET)"
	@echo "  $(GREEN)setup$(RESET)          - Complete step-by-step configuration"
	@echo "  $(GREEN)setup-firebase$(RESET) - Only configure Firebase (if you already have Flutter)"
	@echo "  $(GREEN)configure-env$(RESET)  - Only configure .env file"
	@echo ""
	@echo "$(CYAN)$(BOLD)DEVELOPMENT:$(RESET)"
	@echo "  $(GREEN)web$(RESET)            - Run web app in Chrome (simple)"
	@echo "  $(GREEN)dev$(RESET)            - Run in development mode with hot reload"
	@echo "  $(GREEN)web-release$(RESET)    - Run production build locally"
	@echo "  $(GREEN)build$(RESET)          - Build for production"
	@echo "  $(GREEN)analyze$(RESET)        - Code analysis"
	@echo "  $(GREEN)clean$(RESET)          - Clean previous builds"
	@echo ""
	@echo "$(CYAN)$(BOLD)DEPLOYMENT:$(RESET)"
	@echo "  $(GREEN)deploy$(RESET)         - Complete deployment to Firebase (builds first)"
	@echo "  $(GREEN)deploy-only$(RESET)    - Deploy without rebuilding (use after make build)"
	@echo "  $(GREEN)deploy-check$(RESET)   - Verify configuration before deploy"
	@echo "  $(GREEN)status$(RESET)         - View site status"
	@echo "  $(GREEN)logs$(RESET)           - View Firebase logs"
	@echo "  $(GREEN)open$(RESET)           - Open site in browser"
	@echo ""
	@echo "$(CYAN)$(BOLD)UTILITIES:$(RESET)"
	@echo "  $(GREEN)check-deps$(RESET)     - Verify installed dependencies"
	@echo "  $(GREEN)install-deps$(RESET)   - Install missing dependencies"
	@echo "  $(GREEN)verify$(RESET)         - Verify complete configuration"
	@echo ""
	@echo "$(CYAN)$(BOLD)If colors don't work in your terminal:$(RESET)"
	@echo "  $(GREEN)NO_COLOR=1 make setup$(RESET)  # Setup without colors"

# ===============================================
# 🔧 COMPLETE SETUP - Initial configuration
# ===============================================
setup: check-deps install-deps setup-firebase configure-env verify setup-complete

# ===============================================
# 📦 VERIFY DEPENDENCIES
# ===============================================
check-deps:
	@echo "$(CYAN)$(BOLD)📦 Checking dependencies...$(RESET)"
	@echo ""
	@echo "$(YELLOW)Checking Flutter...$(RESET)"
	@if command -v flutter >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Flutter installed: $$(flutter --version | head -1)$(RESET)"; \
	else \
		echo "$(RED)❌ Flutter not found$(RESET)"; \
		echo "$(YELLOW)Install Flutter from: https://flutter.dev/docs/get-started/install$(RESET)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(YELLOW)Checking Dart...$(RESET)"
	@if command -v dart >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Dart installed: $$(dart --version | head -1)$(RESET)"; \
	else \
		echo "$(RED)❌ Dart not found$(RESET)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(YELLOW)Checking Node.js...$(RESET)"
	@if command -v node >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Node.js installed: $$(node --version)$(RESET)"; \
	else \
		echo "$(RED)❌ Node.js not found$(RESET)"; \
		echo "$(YELLOW)Install Node.js from: https://nodejs.org$(RESET)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(YELLOW)Checking npm...$(RESET)"
	@if command -v npm >/dev/null 2>&1; then \
		echo "$(GREEN)✅ npm installed: $$(npm --version)$(RESET)"; \
	else \
		echo "$(RED)❌ npm not found$(RESET)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(YELLOW)Checking Firebase CLI...$(RESET)"
	@if command -v firebase >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Firebase CLI installed: $$(firebase --version)$(RESET)"; \
	else \
		echo "$(YELLOW)⚠️  Firebase CLI not installed$(RESET)"; \
		echo "$(CYAN)Will be installed automatically...$(RESET)"; \
	fi
	@echo ""
	@echo "$(YELLOW)Checking Chrome...$(RESET)"
	@if command -v google-chrome >/dev/null 2>&1 || command -v chrome >/dev/null 2>&1 || \
		 command -v chromium-browser >/dev/null 2>&1 || command -v "Google Chrome" >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Chrome/Chromium found$(RESET)"; \
	else \
		echo "$(YELLOW)⚠️  Chrome not found$(RESET)"; \
		echo "$(CYAN)Install Chrome for web development$(RESET)"; \
	fi

# ===============================================
# 📥 INSTALL MISSING DEPENDENCIES
# ===============================================
install-deps:
	@echo "$(CYAN)$(BOLD)📥 Installing missing dependencies...$(RESET)"
	@echo ""
	@if ! command -v firebase >/dev/null 2>&1; then \
		echo "$(YELLOW)Installing Firebase CLI...$(RESET)"; \
		npm install -g firebase-tools; \
		echo "$(GREEN)✅ Firebase CLI installed$(RESET)"; \
	fi
	@echo ""
	@echo "$(YELLOW)Installing Flutter dependencies...$(RESET)"
	@flutter pub get
	@echo "$(GREEN)✅ Flutter dependencies installed$(RESET)"
	@echo ""
	@if command -v node >/dev/null 2>&1; then \
		echo "$(YELLOW)Installing HTML processing dependencies...$(RESET)"; \
		npm install; \
		echo "$(GREEN)✅ HTML processing dependencies installed$(RESET)"; \
	else \
		echo "$(YELLOW)⚠️  Node.js not found. Skipping HTML processing dependencies.$(RESET)"; \
	fi

# ===============================================
# 🔥 CONFIGURE FIREBASE
# ===============================================
setup-firebase:
	@echo "$(CYAN)$(BOLD)🔥 Firebase Configuration$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)STEP 1: Create account and project in Firebase$(RESET)"
	@echo "$(CYAN)1. Go to https://console.firebase.google.com$(RESET)"
	@echo "$(CYAN)2. Sign in with your Google account$(RESET)"
	@echo "$(CYAN)3. Click 'Create a project'$(RESET)"
	@echo "$(CYAN)4. Project name: $(BOLD)$(PROJECT_NAME)$(RESET)"
	@echo "$(CYAN)5. Accept terms and create the project$(RESET)"
	@echo "$(CYAN)6. In the project, go to 'Hosting' in the sidebar$(RESET)"
	@echo "$(CYAN)7. Click 'Get started' in Firebase Hosting$(RESET)"
	@echo "$(CYAN)8. Follow the wizard until completing the setup$(RESET)"
	@echo ""
	@printf "$(YELLOW)Have you created the project in Firebase Console? (y/n): $(RESET)"; \
	read confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "$(GREEN)✅ Firebase project created$(RESET)"; \
	else \
		echo "$(RED)❌ Complete the setup in Firebase Console first$(RESET)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(YELLOW)$(BOLD)STEP 2: Login to Firebase CLI$(RESET)"
	@firebase login
	@echo ""
	@echo "$(YELLOW)$(BOLD)STEP 3: Configure local project$(RESET)"
	@echo "$(CYAN)Available projects:$(RESET)"
	@firebase projects:list
	@echo ""
	@printf "$(YELLOW)Enter your Firebase Project ID: $(RESET)"; \
	read project_id; \
	if [ -n "$$project_id" ]; then \
		firebase use $$project_id; \
		echo "FIREBASE_PROJECT_ID=$$project_id" > .env.firebase; \
		sed -i.bak 's/"default": ".*"/"default": "'$$project_id'"/' .firebaserc && rm -f .firebaserc.bak; \
		echo "$(GREEN)✅ Project configured: $$project_id$(RESET)"; \
	else \
		echo "$(RED)❌ Project ID required$(RESET)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(YELLOW)$(BOLD)STEP 4: Verify Hosting configuration$(RESET)"
	@firebase hosting:sites:list
	@echo "$(GREEN)✅ Firebase configured correctly$(RESET)"

# ===============================================
# ⚙️ CONFIGURE ENVIRONMENT VARIABLES
# ===============================================
configure-env:
	@echo "$(CYAN)$(BOLD)⚙️ Configuring environment variables...$(RESET)"
	@echo ""
	@if [ ! -f web/.env ]; then \
		echo "$(YELLOW)Creating web/.env configuration file...$(RESET)"; \
		cp .env.example web/.env; \
		echo "$(GREEN)✅ web/.env file created$(RESET)"; \
	else \
		echo "$(GREEN)✅ web/.env file already exists$(RESET)"; \
	fi
	@echo ""
	@echo "$(CYAN)$(BOLD)Current configuration in web/.env:$(RESET)"
	@cat web/.env
	@echo ""
	@printf "$(YELLOW)Do you want to edit the environment configuration? (y/n): $(RESET)"; \
	read edit_env; \
	if [ "$$edit_env" = "y" ] || [ "$$edit_env" = "Y" ]; then \
		echo "$(CYAN)Opening vim editor...$(RESET)"; \
		$${EDITOR:-vim} web/.env; \
		echo "$(GREEN)✅ Configuration updated$(RESET)"; \
	fi

# ===============================================
# ✅ VERIFY COMPLETE CONFIGURATION
# ===============================================
verify:
	@echo "$(CYAN)$(BOLD)✅ Verifying complete configuration...$(RESET)"
	@echo ""
	@echo "$(YELLOW)Flutter Doctor:$(RESET)"
	@flutter doctor
	@echo ""
	@echo "$(YELLOW)Verifying configuration files...$(RESET)"
	@if [ -f .firebaserc ]; then \
		echo "$(GREEN)✅ .firebaserc exists$(RESET)"; \
		cat .firebaserc; \
	else \
		echo "$(RED)❌ .firebaserc not found$(RESET)"; \
		exit 1; \
	fi
	@echo ""
	@if [ -f firebase.json ]; then \
		echo "$(GREEN)✅ firebase.json exists$(RESET)"; \
	else \
		echo "$(RED)❌ firebase.json not found$(RESET)"; \
		exit 1; \
	fi
	@echo ""
	@if [ -f web/.env ]; then \
		echo "$(GREEN)✅ web/.env exists$(RESET)"; \
	else \
		echo "$(YELLOW)⚠️  web/.env not found$(RESET)"; \
	fi
	@echo ""
	@echo "$(YELLOW)Verifying Firebase authentication...$(RESET)"
	@firebase projects:list > /dev/null && echo "$(GREEN)✅ Firebase authenticated$(RESET)" || echo "$(RED)❌ Firebase not authenticated$(RESET)"

# ===============================================
# 🎉 SETUP COMPLETED
# ===============================================
setup-complete:
	@echo ""
	@echo "$(GREEN)$(BOLD)🎉 SETUP COMPLETE!$(RESET)"
	@echo ""
	@echo "$(CYAN)$(BOLD)Next steps:$(RESET)"
	@echo "$(YELLOW)1. Edit your personal configuration:$(RESET)"
	@echo "   - assets/config/website_config_default.json (Spanish)"
	@echo "   - assets/config/website_config_english.json (English)"
	@echo ""
	@echo "$(YELLOW)2. For development:$(RESET)"
	@echo "   $(CYAN)make dev$(RESET)     # Run in development mode"
	@echo ""
	@echo "$(YELLOW)3. For deployment:$(RESET)"
	@echo "   $(CYAN)make deploy$(RESET)  # Deploy to Firebase"
	@echo ""
	@echo "$(YELLOW)4. Useful commands:$(RESET)"
	@echo "   $(CYAN)make help$(RESET)    # View all available commands"
	@echo "   $(CYAN)make status$(RESET)  # View site status"
	@echo "   $(CYAN)make open$(RESET)    # Open site in browser"

# ===============================================
# 🔧 DEVELOPMENT COMMANDS
# ===============================================
web:
	@echo "$(CYAN)$(BOLD)🌐 Running web app in Chrome...$(RESET)"
	@flutter run -d chrome

dev:
	@echo "$(CYAN)$(BOLD)🔧 Running in development mode with hot reload...$(RESET)"
	@flutter run -d chrome --hot

web-release:
	@echo "$(CYAN)$(BOLD)🚀 Running production build locally...$(RESET)"
	@echo "$(YELLOW)Building for production...$(RESET)"
	@flutter build web --release
	@echo "$(YELLOW)Processing HTML for SEO...$(RESET)"
	@if command -v node >/dev/null 2>&1; then \
		node scripts/process-html.js && echo "$(GREEN)✅ HTML processing completed$(RESET)" || \
		(echo "$(RED)❌ HTML processing failed$(RESET)" && exit 1); \
	else \
		echo "$(YELLOW)⚠️  Node.js not found. Skipping HTML processing.$(RESET)"; \
	fi
	@echo "$(YELLOW)Starting local server on port 8080...$(RESET)"
	@echo "$(CYAN)Open: http://localhost:8080$(RESET)"
	@cd build/web && python3 -m http.server 8080

build:
	@echo "$(CYAN)$(BOLD)🔨 Building for production...$(RESET)"
	@flutter build web --release
	@echo "$(CYAN)$(BOLD)🔧 Processing HTML for SEO...$(RESET)"
	@if command -v node >/dev/null 2>&1; then \
		if [ ! -d "node_modules" ]; then \
			echo "$(YELLOW)📦 Installing HTML processing dependencies...$(RESET)"; \
			npm install; \
		fi; \
		node scripts/process-html.js && echo "$(GREEN)✅ HTML processing completed$(RESET)" || \
		(echo "$(RED)❌ HTML processing failed$(RESET)" && exit 1); \
	else \
		echo "$(YELLOW)⚠️  Node.js not found. Skipping HTML processing.$(RESET)"; \
		echo "$(CYAN)Install Node.js to enable SEO optimization.$(RESET)"; \
	fi

analyze:
	@echo "$(CYAN)$(BOLD)🔍 Analyzing code...$(RESET)"
	@flutter analyze

clean:
	@echo "$(CYAN)$(BOLD)🧹 Cleaning previous builds...$(RESET)"
	@flutter clean
	@flutter pub get

# ===============================================
# 🚀 DEPLOYMENT
# ===============================================
deploy-check:
	@echo "$(CYAN)$(BOLD)🔍 Verifying configuration before deploy...$(RESET)"
	@echo ""
	@echo "$(YELLOW)Verifying necessary files...$(RESET)"
	@if [ -f web/.env ]; then \
		echo "$(GREEN)✅ web/.env found$(RESET)"; \
	else \
		echo "$(RED)❌ web/.env not found$(RESET)"; \
		echo "$(CYAN)Run: make configure-env$(RESET)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(YELLOW)Verifying Firebase authentication...$(RESET)"
	@firebase projects:list > /dev/null 2>&1 && echo "$(GREEN)✅ Firebase authenticated$(RESET)" || (echo "$(RED)❌ Firebase authentication failed$(RESET)" && exit 1)
	@echo ""
	@echo "$(GREEN)✅ Configuration verified successfully$(RESET)"

deploy-only: deploy-check
	@echo "$(CYAN)$(BOLD)🚀 Deploying to Firebase (no rebuild)...$(RESET)"
	@if [ ! -d "build/web" ]; then \
		echo "$(RED)❌ No build found. Run 'make build' first$(RESET)"; \
		exit 1; \
	fi
	@chmod +x scripts/deploy.sh
	@scripts/deploy.sh

deploy: deploy-check clean build
	@echo "$(CYAN)$(BOLD)🚀 Deploying to Firebase (with rebuild)...$(RESET)"
	@chmod +x scripts/deploy.sh
	@scripts/deploy.sh

status:
	@echo "$(CYAN)$(BOLD)📊 Site status...$(RESET)"
	@firebase hosting:sites:list
	@echo ""
	@if [ -f .env.firebase ]; then \
		source .env.firebase; \
		echo "$(YELLOW)Site URL:$(RESET) https://$$FIREBASE_PROJECT_ID.web.app"; \
		echo "$(YELLOW)Console:$(RESET) https://console.firebase.google.com/project/$$FIREBASE_PROJECT_ID"; \
	fi

logs:
	@echo "$(CYAN)$(BOLD)📋 Firebase logs...$(RESET)"
	@firebase hosting:channels:list

open:
	@echo "$(CYAN)$(BOLD)🌐 Opening website...$(RESET)"
	@if [ -f .env.firebase ]; then \
		source .env.firebase; \
		open "https://$$FIREBASE_PROJECT_ID.web.app" 2>/dev/null || \
		xdg-open "https://$$FIREBASE_PROJECT_ID.web.app" 2>/dev/null || \
		echo "$(YELLOW)Open manually: https://$$FIREBASE_PROJECT_ID.web.app$(RESET)"; \
	else \
		echo "$(RED)❌ Could not determine project URL$(RESET)"; \
		echo "$(CYAN)Run: make status$(RESET)"; \
	fi

# ===============================================
# 📝 ADDITIONAL INFORMATION
# ===============================================
info:
	@echo "$(CYAN)$(BOLD)📝 Project Information$(RESET)"
	@echo ""
	@echo "$(YELLOW)Important file structure:$(RESET)"
	@echo "├── web/.env                    # Environment variables for production"
	@echo "├── assets/config/              # Website configuration"
	@echo "│   ├── website_config_default.json  # Spanish configuration"
	@echo "│   └── website_config_english.json  # English configuration"
	@echo "├── firebase.json               # Firebase Hosting configuration"
	@echo "├── .firebaserc                 # Active Firebase project"
	@echo "└── scripts/deploy.sh           # Deployment script"
	@echo ""
	@echo "$(YELLOW)Important URLs:$(RESET)"
	@echo "🔥 Firebase Console: https://console.firebase.google.com"
	@echo "📖 Flutter Web Docs: https://flutter.dev/web"
	@echo "🚀 Firebase Hosting: https://firebase.google.com/docs/hosting"
	@echo ""
	@echo "$(YELLOW)Recommended configuration:$(RESET)"
	@echo "1. Configure your personal information in JSON files"
	@echo "2. Customize colors and themes"
	@echo "3. Add your projects and experience"
	@echo "4. Configure Google Analytics in web/index.html"
	@echo "5. Customize meta tags for SEO"

# ===============================================
# 🆘 TROUBLESHOOTING
# ===============================================
troubleshoot:
	@echo "$(CYAN)$(BOLD)🆘 Common Problem Solutions$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)❌ Error: Firebase CLI not found$(RESET)"
	@echo "$(CYAN)Solution: npm install -g firebase-tools$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)❌ Error: Flutter not found$(RESET)"
	@echo "$(CYAN)Solution: Install Flutter from https://flutter.dev$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)❌ Error: Permission denied in scripts/deploy.sh$(RESET)"
	@echo "$(CYAN)Solution: chmod +x scripts/deploy.sh$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)❌ Error: Firebase project not found$(RESET)"
	@echo "$(CYAN)Solution: make setup-firebase$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)❌ Error: Build failed$(RESET)"
	@echo "$(CYAN)Solutions:$(RESET)"
	@echo "  1. make clean"
	@echo "  2. flutter pub get"
	@echo "  3. flutter analyze"
	@echo ""
	@echo "$(YELLOW)$(BOLD)❌ Loader doesn't work in production$(RESET)"
	@echo "$(CYAN)Solution: Verify that web/.env has the correct configuration$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)❌ Images don't load$(RESET)"
	@echo "$(CYAN)Solution: Images must be in web/ for production$(RESET)"

# Default configuration
.DEFAULT_GOAL := help