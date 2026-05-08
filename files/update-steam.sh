#!/usr/bin/env bash
# Updates steam.nix to the latest version of the Steam macOS client
# by fetching the manifest from Steam's CDN.
set -euo pipefail

CDN_ROOT="https://steamcdn-a.akamaihd.net/client"
CHANNEL="steam_client_osx"

cd "$(dirname "$0")/../overlays"

echo "Fetching $CHANNEL manifest from CDN..."
manifest=$(curl -fsSL "$CDN_ROOT/$CHANNEL")

# The manifest is in VDF format. Extract:
#   - the top-level "version" key
#   - the "appdmg_osx" package's "file" (skipping the steamchina variant)
#   - the corresponding "sha2" within a few lines after "file"
version=$(printf '%s\n' "$manifest" | awk -F'"' '/"version"/{print $4; exit}')
file=$(printf '%s\n' "$manifest" | grep -oE 'appdmg_osx\.zip\.[a-f0-9]+' | head -1)
sha2=$(printf '%s\n' "$manifest" | grep -F -A5 "\"$file\"" | grep '"sha2"' | head -1 | awk -F'"' '{print $4}')

if [[ -z "$version" || -z "$file" || -z "$sha2" ]]; then
  echo "Failed to parse manifest" >&2
  exit 1
fi

sri=$(nix-hash --type sha256 --to-sri "$sha2")

printf 'version: %s\nfile:    %s\nhash:    %s\n' "$version" "$file" "$sri"

sed -i.bak \
  -e "s|version = \"[0-9]*\";|version = \"$version\";|" \
  -e "s|appdmg_osx\.zip\.[a-f0-9]*|$file|" \
  -e "s|hash = \"sha256-[A-Za-z0-9+/=]*\";|hash = \"$sri\";|" \
  steam.nix

rm steam.nix.bak
echo "Updated steam.nix"
