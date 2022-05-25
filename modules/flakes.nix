let
  # Ensure the exact version of Nix has been manually verified
  flakesStillExperimental = lib: version:
  #       version == "2.8.1"      ||                 version < 2.8.1
    lib.hasPrefix "2.8.1" version || builtins.compareVersions "2.8.1" version == 1;
in {
  nixosModule = { pkgs, lib, ... }: {
    nix.extraOptions = (assert (flakesStillExperimental lib pkgs.nix.version); ''
      experimental-features = nix-command flakes
    '');
  };

  hmModule = { nixos, pkgs, lib, ... }: {
    xdg.configFile."nix/nix.conf".text = (assert (flakesStillExperimental lib pkgs.nix.version); ''
      experimental-features = nix-command flakes
    '');

    home.packages = lib.mkIf (!nixos) (builtins.attrValues {
      # Necessary for non-NixOS systems which won't have the dirtiest version of Nix
      inherit (pkgs) nix;
    });
  };
}
