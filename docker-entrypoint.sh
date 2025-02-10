#!/bin/sh

# Ensure /data is writable, then place a default settings.js if missing
if [ ! -f "/data/settings.js" ]; then
  cp /usr/src/node-red/config/settings.js /data/settings.js
fi

exec npm start -- --userDir /data
