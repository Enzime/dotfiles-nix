{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  inputs.home-manager.url = github:nix-community/home-manager;
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-utils-plus.url = github:gytis-ivaskevicius/flake-utils-plus;

  outputs = inputs@{ self, nixpkgs, home-manager, flake-utils-plus }:

  let
    inherit (nixpkgs.lib) foldr getAttr mapAttrs' mapAttrsToList mkIf nameValuePair recursiveUpdate removeSuffix;

    importFrom = path: filename: import (path + ("/" + filename));
    importOverlay = filename: _: importFrom ./overlays filename;

    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      overlays = mapAttrsToList importOverlay (builtins.readDir ./overlays);
    };

    modules = mapAttrs' (
      filename: _: nameValuePair
        (removeSuffix ".nix" filename)
        (importFrom ./modules filename)
    ) (builtins.readDir ./modules);

    mkConfigurations = configs: foldr (recursiveUpdate) {} (map (mkConfiguration) configs);
    mkConfiguration = { system, nixos ? false, host, hostSuffix ? "-nixos", user, modules }:
    let
      hostname = "${host}${hostSuffix}";
      nixosModules = map (getAttr "nixosModule") (builtins.filter (builtins.hasAttr "nixosModule") modules);
      hmModules = map (getAttr "hmModule") (builtins.filter (builtins.hasAttr "hmModule") modules);
      home = [ ./home.nix ./hosts/${host}/home.nix ] ++ hmModules;
    in {
      # nix build ~/.config/nixpkgs#nixosConfigurations.enzime@phi-nixos.config.system.build.toplevel
      # OR
      # nixos-rebuild build --flake ~/.config/nixpkgs#phi-nixos
      nixosConfigurations = if nixos then { ${hostname} = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ({ inputs, ... }: {
            environment.systemPackages = [ home-manager.packages.${system}.home-manager ];

            # Add flake revision to `nixos-version --json`
            system.configurationRevision = mkIf (self ? rev) self.rev;

            # Generate `/etc/nix/inputs/<input>` and `/etc/nix/registry.json` using FUP
            nix.linkInputs = true;
            nix.generateRegistryFromInputs = true;
          })
          flake-utils-plus.nixosModules.autoGenFromInputs
          ./configuration.nix
          ./hosts/${host}/configuration.nix
        ] ++ nixosModules ++ [
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;

            # Required for `fonts.fontconfig.enable = true;`
            home-manager.useUserPackages = true;

            home-manager.users.${user}.imports = home;
          }
        ];
        # Required for `flake-utils-plus` to generate stuff
        specialArgs = { inherit inputs; };
      }; } else { };

      # nix build ~/.config/nixpkgs#homeConfigurations.enzime@phi-nixos.activationPackage
      # OR
      # home-manager build --flake ~/.config/nixpkgs#enzime@phi-nixos
      homeConfigurations."${user}@${hostname}" = home-manager.lib.homeManagerConfiguration {
        inherit system pkgs;
        configuration = {};
        homeDirectory = "/home/${user}";
        username = user;
        extraModules = home;
      };
    };
  in mkConfigurations [
    {
      system = "x86_64-linux";
      nixos = true;
      host = "phi";
      user = "enzime";
      modules = builtins.attrValues {
        inherit (modules) duckdns fonts gaming i3 samba thunar;
      };
    }
    {
      system = "x86_64-linux";
      host = "tau";
      hostSuffix = "endeavour";
      user = "enzime";
      modules = builtins.attrValues {
        inherit (modules) i3 work;
      };
    }
    {
      system = "x86_64-linux";
      nixos = true;
      host = "zeta";
      user = "enzime";
      modules = builtins.attrValues {
        inherit (modules) gnome work;
      };
    }
  ];
}
