#!/bin/bash

# Deployment script for Firebase Hosting
echo "🚀 Starting website deployment..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed"
    echo "Install Firebase CLI with: npm install -g firebase-tools"
    exit 1
fi

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Build for web
echo "🔨 Building web application..."
flutter build web --release

# Verify build was successful
if [ ! -d "build/web" ]; then
    echo "❌ Error: build/web directory doesn't exist. Build failed."
    exit 1
fi

# Process HTML for SEO
echo "🔧 Processing HTML templates for SEO..."
if command -v node &> /dev/null; then
    node scripts/process-html.js
    if [ $? -eq 0 ]; then
        echo "✅ HTML processing completed"
    else
        echo "❌ Error: HTML processing failed"
        exit 1
    fi
else
    echo "⚠️  Warning: Node.js not found. Skipping HTML processing."
    echo "Install Node.js to enable SEO optimization."
fi

# Deploy to Firebase
echo "🚀 Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "✅ Deployment completed!"
echo "📱 Your website is available at the Firebase Hosting URL"