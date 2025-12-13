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

      sshd = {
        module = {
          name = "sshd";
          input = "clan-core";
        };
        roles.server.tags.all = { };
        roles.client.tags.all = { };
      };

      root-password = {
        module = {
          name = "users";
          input = "clan-core";
        };
        roles.default.tags.nixos = { };
        roles.default.settings.user = "root";
        roles.default.settings.prompt = false;
      };

      primary-user-password = {
        module = {
          name = "users";
          input = "clan-core";
        };
        roles.default.tags.nixos = { };
        roles.default.settings.prompt = false;
      };

      wifi = {
        module = {
          name = "wifi";
          input = "clan-core";
        };
        roles.default.settings.networks.home = { };
        roles.default.settings.networks.hotspot = { };
        roles.default.settings.networks.jaden = { };
        roles.default.tags.wireless-personal = { };
      };

      test-synapse = {
        module = {
          name = "matrix-synapse";
          input = "clan-core";
        };
        roles.default.machines.gaia.settings = {
          acmeEmail = "letsencrypt@enzim.ee";
          server_tld = "test.enzim.ee";
          app_domain = "matrix.test.enzim.ee";
          users.admin.admin = true;
          users.enzime = { };
        };
      };
    };

    specialArgs = { inherit inputs; };
  };
}
