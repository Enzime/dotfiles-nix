let
  shared = { config, pkgs, lib, ... }: {
    nix.package = lib.mkDefault pkgs.nix;
    # a < b | a == b
    nix.settings.experimental-features =
      assert builtins.compareVersions config.nix.package.version "2.18.1" < 1;
      "nix-command flakes repl-flake";
  };
in {
  darwinModule = { ... }: { imports = [ shared ]; };

  nixosModule = { ... }: { imports = [ shared ]; };

  hmModule = { nixos, pkgs, lib, ... }: {
    imports = [ shared ];

    home.packages = lib.mkIf (!nixos) (builtins.attrValues {
      # Necessary for non-NixOS systems which won't have the dirtiest version of Nix
      inherit (pkgs) nix;
    });
  };
}
