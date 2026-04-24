#!/bin/bash

# Exit on any error
set -e

echo "1. Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

echo "2. Setting up Flutter path..."
export PATH="$PATH:`pwd`/flutter/bin"

echo "3. Running Flutter doctor to initialize..."
flutter doctor -v

echo "4. Building Flutter web app..."
flutter build web --release

echo "Build complete! Output is in build/web"
