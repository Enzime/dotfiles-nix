# shellcheck shell=bash

set -e
set -o pipefail
shopt -s inherit_errexit


profile=$1; shift 1
pathToConfig=$1; shift 1

systemNumber=$(
  nix-env -p "$profile" --list-generations |
  sed -n '/current/ {s/ *\([0-9]*\).*/\1/; p}'
)
systemCfg="/nix/var/nix/gcroots/system-cfg/$systemNumber"

# If a folder already exists for this generation
# it means we're either switching to the exact
# same generation (and thus this should be a no-op)
# or someone deleted a generation and is now
# overwriting it and so we also want to overwrite
# the corresponding system config folder.
if [[ -d "$systemCfg" ]]; then
  rm -rf $systemCfg
fi

mkdir -p "$systemCfg"
ln -s "$(realpath "$pathToConfig/dotfiles")" "$systemCfg/dotfiles"

while [ "$#" -gt 0 ]; do
    i="$1"; shift 1
    case "$i" in
      --override-input)
        input="$1"; shift 1
        replacement="$1"; shift 1

        pathInStore=$(nix flake metadata --json "$replacement")
        target="$systemCfg/inputs/$input"

        mkdir -p "$(dirname $target)"
        ln -s "$pathInStore" "$target"
        ;;
    esac
done
