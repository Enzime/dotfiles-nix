{ lib, flake-parts-lib, ... }: {
  imports = [
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "terraformConfigurations";
      option = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };
      file = ./configurations.nix;
    })
  ];

  options = {
    flake.baseDarwinConfigurations = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = { };
    };

    flake.baseNixosConfigurations = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = { };
    };

    flake.homeConfigurations = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = { };
    };
  };
}
