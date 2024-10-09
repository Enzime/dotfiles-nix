let
  shared = { inputs, keys, pkgs, lib, ... }: {
    nix.settings.substituters = [ "https://enzime.cachix.org" ];
    nix.settings.trusted-public-keys = builtins.attrValues {
      inherit (keys.signing) aether chi-linux-builder echo;

      "enzime.cachix.org" = keys.signing."enzime.cachix.org";
    };
  };
in {
  nixosModule = shared;

  darwinModule = shared;

  homeModule = { pkgs, ... }: {
    home.packages = builtins.attrValues { inherit (pkgs) cachix; };
  };
}

