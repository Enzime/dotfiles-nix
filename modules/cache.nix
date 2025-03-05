let
  shared = { inputs, keys, pkgs, lib, ... }: {
    nix.settings.substituters =
      [ "https://enzime.cachix.org" "https://cache.clan.lol" ];
    nix.settings.trusted-public-keys = builtins.attrValues {
      inherit (keys.signing) aether chi-linux-builder echo;

      "enzime.cachix.org" = keys.signing."enzime.cachix.org";
      "cache.clan.lol" = keys.signing."cache.clan.lol";
    };
  };
in {
  nixosModule = shared;

  darwinModule = shared;

  homeModule = { pkgs, ... }: {
    home.packages = builtins.attrValues { inherit (pkgs) cachix; };
  };
}

