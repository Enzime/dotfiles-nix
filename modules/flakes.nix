let
  shared = { pkgs, ... }: {
    nix.package = pkgs.nixVersions.latest;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.warn-dirty = false;
  };
in {
  darwinModule = shared;

  nixosModule = shared;

  homeModule = { config, lib, ... }@args: {
    imports = [ shared ];

    home.packages = builtins.attrValues
      (lib.optionalAttrs (!args ? osConfig) { inherit (config.nix) package; });

    nix = lib.optionalAttrs (args ? osConfig) {
      package = lib.mkForce args.osConfig.nix.package;
    };
  };
}
