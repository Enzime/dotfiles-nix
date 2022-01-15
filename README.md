# Inspiration

- `overlays/paperwm/flake.nix` is based off https://github.com/nix-community/neovim-nightly-overlay/blob/master/flake.nix

# Setup

## NixOS

Add to `/etc/nixos/configuration.nix`:

```nix
{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
```

## Non-NixOS

Add to `~/.config/nix/nix.conf`:

```
experimental-features = nix-command flakes
```

# Usage

```
nixos-rebuild build-vm --flake github:Enzime/dotfiles-nix#phi-nixos
```

```
home-manager switch --flake github:Enzime/dotfiles-nix#enzime@phi-nixos
```
