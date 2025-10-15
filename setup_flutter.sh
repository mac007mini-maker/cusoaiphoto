#!/bin/bash
# Flutter SDK Installation Script for Replit
# This script installs Flutter 3.x stable for use in the Viso AI project

set -e

FLUTTER_DIR="/home/runner/flutter"

echo "🔧 Setting up Flutter SDK for Replit..."

# Check if Flutter is already installed
if [ -d "$FLUTTER_DIR" ] && [ -x "$FLUTTER_DIR/bin/flutter" ]; then
    echo "✅ Flutter SDK already installed at $FLUTTER_DIR"
    export PATH="$FLUTTER_DIR/bin:$PATH"
    flutter --version 2>&1 | head -5 || echo "Flutter installed but may need initialization"
    exit 0
fi

# Install unzip if not available (Replit has nix package manager)
if ! command -v unzip &> /dev/null; then
    echo "📦 Installing unzip via nix..."
    if command -v nix-env &> /dev/null; then
        nix-env -iA nixpkgs.unzip 2>&1 | tail -5
    else
        echo "❌ Cannot install unzip automatically. Please install it manually:"
        echo "   Via Replit UI: Tools → Packages → Search 'unzip' → Install"
        echo "   Or run: nix-env -iA nixpkgs.unzip"
        exit 1
    fi
    
    # Verify installation
    if ! command -v unzip &> /dev/null; then
        echo "❌ unzip installation failed. Please install manually."
        exit 1
    fi
fi

# Clone Flutter SDK
echo "📥 Downloading Flutter SDK (stable branch)..."
if [ ! -d "$FLUTTER_DIR" ]; then
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
fi

# Add to PATH
export PATH="$FLUTTER_DIR/bin:$PATH"

# Run flutter doctor to trigger initial setup
echo "🔧 Initializing Flutter (this may take a few minutes)..."
timeout 300 flutter doctor || echo "Flutter doctor timed out but SDK should be functional"

echo "✅ Flutter SDK setup complete!"
echo "📝 To use Flutter, run: export PATH=\"$FLUTTER_DIR/bin:\$PATH\""
