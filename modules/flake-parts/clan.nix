{ self, inputs, ... }: {
  clan = {
    meta.name = "Enzime";

    pkgsForSystem = system: inputs.nixpkgs.legacyPackages.${system};

    secrets.age.plugins = [ "age-plugin-1p" ];

    machines = builtins.mapAttrs (hostname: configuration: {
      imports = configuration._module.args.modules;

      config = { _module.args = configuration._module.specialArgs; };
    }) (self.baseNixosConfigurations // self.baseDarwinConfigurations);

    inventory.machines =
      builtins.mapAttrs (hostname: _: { machineClass = "darwin"; })
      self.baseDarwinConfigurations;

    inventory.instances = {
      emergency-access = {
        module = {
          name = "emergency-access";
          input = "clan-core";
        };
        roles.default.tags.nixos = { };
      };
    };

    specialArgs = { inherit inputs; };
  };
}
