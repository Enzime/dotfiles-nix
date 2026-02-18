{
  nixosModule =
    {
      config,
      inputs,
      lib,
      extendModules,
      ...
    }:
    let
      systems = import inputs.systems;

      forAllSystems = lib.genAttrs systems;

      forLinuxSystems = lib.genAttrs (lib.filter (lib.hasSuffix "linux") systems);

    in
    {
      options = {
        extendModules = lib.mkOption { default = extendModules; };

        as = forLinuxSystems (
          system:
          lib.mkOption {
            description = ''
              Extra configuration when using `as.${system}`
            '';
            inherit
              (extendModules {
                modules = [ { nixpkgs.hostPlatform = lib.mkOverride 0 system; } ];
              })
              type
              ;
            default = { };
            visible = "shallow";
          }
        );

        on = forAllSystems (
          system:
          lib.mkOption {
            description = ''
              Extra configuration when using `on.${system}`
            '';
            inherit
              (config.virtualisation.vmVariant.extendModules {
                modules = [
                  (
                    let
                      shared =
                        { pkgs, ... }:
                        {
                          virtualisation.host.pkgs = import pkgs.path {
                            inherit system;
                            inherit (pkgs) config overlays;
                          };
                        };
                    in
                    {
                      virtualisation.vmVariant = shared;
                      virtualisation.vmVariantWithBootLoader = shared;
                      virtualisation.vmVariantWithDisko = shared;
                    }
                  )
                ];
              })
              type
              ;
            default = { };
            visible = "shallow";
          }
        );
      };

      # uses extendModules to generate a type
      meta.buildDocsInSandbox = false;
    };
}
