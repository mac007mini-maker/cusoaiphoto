#!/usr/bin/env python3
"""
Railway deployment entry point
Imports Flask app from api/index.py
Version: 1.0.1 - With API keys configured
"""
import os
import sys

# Add current directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Import Flask app from api/index.py
from api.index import app

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
