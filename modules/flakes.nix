let
  shared = { pkgs, lib, ... }: let
    # Ensure the exact version of Nix has been manually verified
    flakesStillExperimental = version:
      #       version == 2.13.3      ||                 version < 2.13.3
      lib.hasPrefix "2.13.3" version || builtins.compareVersions "2.13.3" version == 1;
  in {
    nix.package = lib.mkDefault pkgs.nix;
    nix.settings.experimental-features = assert (flakesStillExperimental pkgs.nix.version); "nix-command flakes";
  };
in {
  darwinModule = { ... }: {
    imports = [ shared ];
  };

  nixosModule = { ... }: {
    imports = [ shared ];
  };

  hmModule = { nixos, pkgs, lib, ... }: {
    imports = [ shared ];

    home.packages = lib.mkIf (!nixos) (builtins.attrValues {
      # Necessary for non-NixOS systems which won't have the dirtiest version of Nix
      inherit (pkgs) nix;
    });
  };
}
