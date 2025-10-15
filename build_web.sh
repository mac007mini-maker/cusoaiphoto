#!/bin/bash

# Build script for Flutter web app in Replit environment
# This script builds the app and patches it to use HTML renderer instead of CanvasKit
# because Replit's preview environment doesn't support WebGL/GPU acceleration

echo "Building Flutter web app..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo "Build successful. Patching for HTML renderer..."
    
    # Change renderer from canvaskit to html in the build config
    sed -i 's/"renderer":"canvaskit"/"renderer":"html"/g' build/web/index.html
    
    echo "Patching complete. The app is ready to serve on port 5000."
    echo "Run: python3 -m http.server 5000 --directory build/web --bind 0.0.0.0"
else
    echo "Build failed!"
    exit 1
fi
