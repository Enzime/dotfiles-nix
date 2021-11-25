# Inspiration

- `using/X` is based off https://github.com/jonringer/nixpkgs-config
- `overlays/paperwm/flake.nix` is based off https://github.com/nix-community/neovim-nightly-overlay/blob/master/flake.nix

# Setup

## NixOS

Add to `/etc/nixos/configuration.nix`:

```nix
nix.extraOptions = ''
  experimental-features = nix-command flakes
'';
```

## Non-NixOS

Add to `~/.config/nix/nix.conf`:

```
experimental-features = nix-command flakes
```

# Usage

```
home-manager switch /path/to/your/clone#enzime@phi-nixos
```

```
sudo nixos-rebuild switch /path/to/your/clone#phi-nixos
```
