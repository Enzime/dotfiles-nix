{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  inputs.home-manager.url = github:nix-community/home-manager;
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, home-manager }:

  let
    inherit (nixpkgs.lib) foldr getAttr mapAttrs' mapAttrsToList mkIf nameValuePair recursiveUpdate removeSuffix;

    importOverlay = filename: _: importFrom ./overlays filename;

    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      overlays = mapAttrsToList importOverlay (builtins.readDir ./overlays);
    };

    importFrom = path: filename: import (path + ("/" + filename));

    modules = mapAttrs' (
      filename: _: nameValuePair
        (removeSuffix ".nix" filename)
        (importFrom ./modules filename)
    ) (builtins.readDir ./modules);

    mkConfigurations = configs: foldr (recursiveUpdate) {} (map (mkConfiguration) configs);
    mkConfiguration = { system, nixos ? false, host, hostSuffix ? "-nixos", user, modules, using }:
    let
      hostname = "${host}${hostSuffix}";
      nixosModules = map (getAttr "nixosModule") (builtins.filter (builtins.hasAttr "nixosModule") modules);
      hmModules = map (getAttr "hmModule") (builtins.filter (builtins.hasAttr "hmModule") modules);
      home = [ ./home.nix ] ++ hmModules;

      extraSpecialArgs = {
        inherit using;
        hostname = host;
      };
    in {
      # nix build ~/.config/nixpkgs#nixosConfigurations.enzime@phi-nixos.config.system.build.toplevel
      # OR
      # nixos-rebuild build --flake ~/.config/nixpkgs#phi-nixos
      nixosConfigurations = if nixos then { ${hostname} = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./configuration.nix
          ./hosts/${host}/configuration.nix
        ] ++ nixosModules ++ [
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.users.${user}.imports = home;
            home-manager.extraSpecialArgs = extraSpecialArgs;
          }
        ];
      }; } else { };

      # nix build ~/.config/nixpkgs#homeConfigurations.enzime@phi-nixos.activationPackage
      # OR
      # home-manager build --flake ~/.config/nixpkgs#enzime@phi-nixos
      homeConfigurations."${user}@${hostname}" = home-manager.lib.homeManagerConfiguration {
        inherit system pkgs extraSpecialArgs;
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
        inherit (modules) duckdns fonts gaming samba thunar;
      };
      using = { i3 = true; };
    }
    {
      system = "x86_64-linux";
      host = "tau";
      hostSuffix = "endeavour";
      user = "enzime";
      modules = builtins.attrValues {
        inherit (modules) work;
      };
      using = { i3 = true; hidpi = true; };
    }
    {
      system = "x86_64-linux";
      nixos = true;
      host = "zeta";
      user = "enzime";
      modules = builtins.attrValues {
        inherit (modules) work;
      };
      using = { gnome = true; };
    }
  ];
}
