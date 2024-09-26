#! /usr/bin/env nix
#! nix shell --inputs-from . nixpkgs#just nixpkgs#git --command just

[private]
[no-exit-message]
justfile *args='default':
    @just {{args}}

[private]
default:
    @just -l

set unstable

[script("bash", "-euxo", "pipefail")]
subflakes:
    TEMP=$(mktemp -d)
    git worktree add --detach $TEMP
    cd $TEMP
    nix flake update systems $(find overlays -mindepth 1 -type d -exec basename {} \; | sed -E 's/^(.*)$/&-overlay/' | paste -sd ' ' -)
    cd - > /dev/null
    git worktree remove --force $TEMP
