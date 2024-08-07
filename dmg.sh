#!/bin/sh
test -f AIME.dmg && rm AIME.dmg
create-dmg \
  --volname "AIME" \
  --volicon "AIME.app/Contents/Resources/AppIcon.icns" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "AIME.app" 200 190 \
  --hide-extension "AIME.app" \
  --app-drop-link 600 185 \
  "AIME.dmg" \
  "AIME.app"