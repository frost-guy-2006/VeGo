#!/bin/bash
set -e

echo "=== VeGo / FreshFlow Web Showcase Build ==="
echo "1. Generating .env configuration..."
echo "SUPABASE_URL=https://xstagwqwesafzirsxhjw.supabase.co" > .env
echo "SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzdGFnd3F3ZXNhZnppcnN4aGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkyNDM1NDAsImV4cCI6MjA4NDgxOTU0MH0.-dy7yonmaOf1brijFlzMiS75ve99aeTPiih0CFoxncU" >> .env

echo "2. Preparing production output directory..."
mkdir -p build/web

echo "3. Deploying VeGo Web Showcase & APK Download Portal..."
cp -rf web_showcase/* build/web/

echo "Build successful! Output ready in build/web."
