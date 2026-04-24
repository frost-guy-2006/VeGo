#!/bin/bash

# Exit on any error
set -e

echo "1. Generating .env file for Flutter..."
# Vercel will inject these environment variables during the build
echo "SUPABASE_URL=https://xstagwqwesafzirsxhjw.supabase.co" > .env
echo "SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzdGFnd3F3ZXNhZnppcnN4aGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkyNDM1NDAsImV4cCI6MjA4NDgxOTU0MH0.-dy7yonmaOf1brijFlzMiS75ve99aeTPiih0CFoxncU" >> .env

echo "2. Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

echo "3. Setting up Flutter path..."
export PATH="$PATH:`pwd`/flutter/bin"

echo "4. Running Flutter doctor to initialize..."
flutter doctor -v

echo "5. Building Flutter web app..."
flutter build web --release

echo "Build complete! Output is in build/web"
