I use Nix to declaratively manage and configure all of my systems everywhere all at once

## Getting started

Due to subflakes being broken in Nix, before you can use this repo you'll need to run:

```
$ nix-shell --pure -I nixpkgs=flake:nixpkgs -p '(import ./shell.nix { }).packages.${builtins.currentSystem}.add-subflakes-to-store' --command add-subflakes-to-store
```

You can then run a NixOS VM on Linux with:

```
$ nix run .#phi-nixos-vm
```

All the possible hostnames are `eris`, `gaia`, `phi-nixos` and `sigma`

## See also

- [Frequently Asked Questions about Nix](https://github.com/hlissner/dotfiles/tree/55194e703d1fe82e7e0ffd06e460f1897b6fc404?tab=readme-ov-file#frequently-asked-questions)
