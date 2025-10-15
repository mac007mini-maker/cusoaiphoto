#!/bin/bash

# Start script for Viso AI - Photo Avatar Headshot App
# This script handles Flutter web build and starts the Python backend server

# Exit on critical errors
set -e

# Setup Flutter SDK
FLUTTER_DIR="/home/runner/flutter"
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
    echo "⚠️  Flutter SDK not found. Running setup..."
    if ! bash setup_flutter.sh; then
        echo "❌ Flutter SDK setup failed. Cannot continue."
        echo "📝 Please check the logs and run: bash setup_flutter.sh"
        exit 1
    fi
fi

# Verify Flutter is now available
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
    echo "❌ Flutter SDK still not available after setup. Aborting."
    exit 1
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# Don't exit on non-critical errors after this point (for Flutter build timeout handling)
set +e

echo "🚀 Starting Viso AI Setup..."

# Ensure build directory exists
mkdir -p build/web

# Check if Flutter web build exists
if [ ! -f "build/web/index.html" ]; then
    echo "📦 Flutter web build not found. Building now..."
    echo "⚠️  This may take 5-10 minutes on first run..."
    
    # Build Flutter web (HTML renderer will be configured in build output)
    flutter build web --release 2>&1 | tail -20 &
    BUILD_PID=$!
    
    # Wait for build to complete or timeout after 8 minutes
    timeout 480 bash -c "while kill -0 $BUILD_PID 2>/dev/null; do sleep 2; done" || true
    
    if [ ! -f "build/web/index.html" ]; then
        echo "⚠️  Flutter build is still in progress..."
        echo "📝 Creating minimal placeholder index.html..."
        
        # Create a minimal placeholder that shows the build is in progress
        cat > build/web/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Viso AI - Building...</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            text-align: center;
            padding: 2rem;
        }
        .spinner {
            border: 4px solid rgba(255,255,255,0.3);
            border-radius: 50%;
            border-top: 4px solid white;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 20px auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎨 Viso AI - Photo Avatar & Headshot</h1>
        <div class="spinner"></div>
        <p>Building Flutter web application...</p>
        <p style="font-size: 0.9em; opacity: 0.8;">This may take a few minutes. Please refresh the page in a moment.</p>
        <script>
            // Auto-refresh every 30 seconds to check if build is complete
            setTimeout(() => location.reload(), 30000);
        </script>
    </div>
</body>
</html>
EOF
        echo "✅ Placeholder page created. Continue building in background..."
    fi
else
    echo "✅ Flutter web build found"
fi

# Start the Python backend server
echo "🌐 Starting Python backend server on port 5000..."
python3 api_server.py
