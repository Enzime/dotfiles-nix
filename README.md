I use Nix to declaratively manage and configure all of my systems everywhere all at once

## Getting started

Due to subflakes being broken in Nix, before you can use this repo you'll need to run:

```
$ ./justfile subflakes
```

You can then run a NixOS VM like so:

```
$ nix run .#nixosConfigurations.phi-nixos.config.system.build.vm
```

## See also

- [Frequently Asked Questions about Nix](https://github.com/hlissner/dotfiles/tree/55194e703d1fe82e7e0ffd06e460f1897b6fc404?tab=readme-ov-file#frequently-asked-questions)
