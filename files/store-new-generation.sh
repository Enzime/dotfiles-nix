#!/bin/bash
set -e
set -o pipefail
shopt -s inherit_errexit


profile=$1; shift 1
pathToConfig=$1; shift 1
configName=$1; shift 1

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
  rm -rf "$systemCfg"
fi

mkdir -p "$systemCfg/bin"

dotfiles=$(realpath "$pathToConfig/etc/nix/inputs/self")
ln -s "$dotfiles" "$systemCfg/dotfiles"

flags=("--flake" "$dotfiles#$configName")

while [ "$#" -gt 0 ]; do
  i="$1"; shift 1

  if [[ $i == "--override-input" ]]; then
    input="$1"; shift 1
    replacement="$1"; shift 1

    # FIXME: handle $input = "home-manager/nixpkgs"
    # Ensure that we're looking at an input that is actually used
    if [[ $(nix flake metadata --json "$dotfiles" --override-input "$input" "$replacement" | jq -r ".locks.nodes.${input}") != "null" ]]; then
      flags+=("--override-input" "$input" "$replacement")

      pathInStore=$(nix flake metadata --json "$replacement" | jq -r ".path")
      target="$systemCfg/inputs/$input"

      mkdir -p "$(dirname "$target")"
      ln -s "$pathInStore" "$target"
    fi
  fi
done

cat > "$systemCfg/bin/build" <<EOF
#!/bin/sh
nixos-rebuild build ${flags[@]}
EOF
chmod a+x "$systemCfg/bin/build"

cat > "$systemCfg/bin/build-vm" <<EOF
#!/bin/sh
nixos-rebuild build-vm ${flags[@]}
EOF
chmod a+x "$systemCfg/bin/build-vm"

cat > "$systemCfg/bin/switch" <<EOF
#!/bin/sh
nixos-rebuild switch ${flags[@]}
EOF
chmod a+x "$systemCfg/bin/switch"
