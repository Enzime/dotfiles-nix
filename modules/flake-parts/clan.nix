{ self, inputs, ... }: {
  clan = {
    meta.name = "Enzime";

    pkgsForSystem = system: inputs.nixpkgs.legacyPackages.${system};

    machines = builtins.mapAttrs (hostname: configuration: {
      imports = configuration._module.args.modules;

      config = { _module.args = configuration._module.specialArgs; };
    }) (self.baseNixosConfigurations // self.baseDarwinConfigurations);

    inventory.machines =
      builtins.mapAttrs (hostname: _: { machineClass = "darwin"; })
      self.baseDarwinConfigurations;

    specialArgs = { inherit inputs; };
  };
}
