{
  inputs.unstable.url = github:NixOS/nixpkgs/nixos-unstable;

  outputs = { self, unstable }: let
    pkgs = import unstable { system = "x86_64-linux"; config.allowUnfree = true; };
  in {
    overlay = final: prev: {
      _1password-gui = pkgs._1password-gui;
      mpv = pkgs.mpv;
      neovim = pkgs.neovim;
      nix-direnv = pkgs.nix-direnv;
    };
  };
}
