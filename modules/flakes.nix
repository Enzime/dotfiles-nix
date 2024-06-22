let
  shared = { config, pkgs, lib, ... }: {
    nix.package = lib.mkDefault pkgs.nix;
    # a < b | a == b
    nix.settings.experimental-features = "nix-command flakes";
    nix.settings.warn-dirty = false;
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
