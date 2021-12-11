{
  inputs.unstable.url = github:NixOS/nixpkgs/nixos-unstable;

  outputs = { self, unstable }: {
    overlay = final: prev: let
      pkgs = import unstable { inherit (prev) system; config.allowUnfree = true; };
    in {
      _1password-gui = pkgs._1password-gui;
      mpv = pkgs.mpv;
      neovim = pkgs.neovim;
      nix-direnv = pkgs.nix-direnv;
    };
  };
}
