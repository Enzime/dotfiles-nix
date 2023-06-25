let
  shared = { pkgs, lib, ... }: {
    nix.package = lib.mkDefault pkgs.nix;
    nix.settings.experimental-features = "nix-command flakes";
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
