#!/bin/bash

PEBBLE=$(find "$GITHUB_WORKSPACE" -path "*/nginx-acme-*/build/get-pebble.pl" -type f 2>/dev/null | head -1)
[ -n "$PEBBLE" ] && echo "TEST_NGINX_PEBBLE_BINARY=$(perl "$PEBBLE")" >> "$GITHUB_ENV"
