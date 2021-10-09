{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  inputs.home-manager.url = github:nix-community/home-manager;
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs:

  let
    inherit (inputs.nixpkgs) lib;
    inherit (inputs.nixpkgs.lib) mapAttrs' mapAttrsToList nameValuePair removeSuffix;

    importFrom = path: filename: import (path + ("/" + filename));

    modules = mapAttrs' (
      filename: _: nameValuePair
        (removeSuffix ".nix" filename)
        (importFrom ./modules filename)
    ) (builtins.readDir ./modules);

    importOverlay = filename: _: importFrom ./overlays filename;

    nixpkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      overlays = mapAttrsToList importOverlay (builtins.readDir ./overlays);
    };
  in {
    # nix build ~/.config/nixpkgs#nixosConfigurations.enzime@phi-nixos.config.system.build.toplevel
    # OR
    # nixos-rebuild build --flake ~/.config/nixpkgs#phi-nixos
    nixosConfigurations.phi-nixos = lib.nixosSystem {
      system = "x86_64-linux";
      pkgs = nixpkgs;
      modules = [
        ./configuration.nix
        ./hosts/phi/configuration.nix
        modules.duckdns.nixosModule
        modules.gaming.nixosModule
        modules.samba.nixosModule
        modules.thunar.nixosModule
        inputs.home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.users.enzime = import ./home.nix;
          home-manager.extraSpecialArgs = {
            hostname = "phi";
            using = { i3 = true; };
          };
          home-manager.sharedModules = lib.optional (lib.hasAttrByPath [ "gaming" "hmModule" ] modules) (modules.gaming.hmModule { pkgs = nixpkgs; })
          ++ lib.optional (lib.hasAttrByPath [ "duckdns" "hmModule" ] modules) (modules.duckdns.hmModule { pkgs = nixpkgs; })
          ++ lib.optional (lib.hasAttrByPath [ "thunar" "hmModule" ] modules) (modules.thunar.hmModule { pkgs = nixpkgs; })
          ++ lib.optional (lib.hasAttrByPath [ "fonts" "hmModule" ] modules) (modules.fonts.hmModule { pkgs = nixpkgs; });
        }
      ];
    };

    nixosConfigurations.zeta-nixos = lib.nixosSystem {
      system = "x86_64-linux";
      pkgs = nixpkgs;
      modules = [
        ./configuration.nix
        ./hosts/zeta/configuration.nix
        inputs.home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.users.enzime = import ./home.nix;
          home-manager.extraSpecialArgs = {
            hostname = "zeta";
            using = { gnome = true; };
          };
        }
      ];
    };

    # nix build ~/.config/nixpkgs#homeConfigurations.enzime@phi-nixos.activationPackage
    # OR
    # home-manager build --flake ~/.config/nixpkgs#enzime@phi-nixos
    homeConfigurations."enzime@phi-nixos" = inputs.home-manager.lib.homeManagerConfiguration {
      system = "x86_64-linux";
      pkgs = nixpkgs;
      configuration = import ./home.nix;
      homeDirectory = "/home/enzime";
      username = "enzime";
      extraModules = [ modules.gaming.hmModule ];
      extraSpecialArgs = {
        hostname = "phi";
        using = { i3 = true; };
      };
    };

    homeConfigurations."enzime@tauendeavour" = inputs.home-manager.lib.homeManagerConfiguration {
      system = "x86_64-linux";
      pkgs = nixpkgs;
      configuration = import ./home.nix;
      homeDirectory = "/home/enzime";
      username = "enzime";
      extraModules = [ modules.work.hmModule ];
      extraSpecialArgs = {
        hostname = "tau";
        using = { i3 = true; hidpi = true; };
      };
    };

    homeConfigurations."enzime@zeta-nixos" = inputs.home-manager.lib.homeManagerConfiguration {
      system = "x86_64-linux";
      pkgs = nixpkgs;
      configuration = import ./home.nix;
      homeDirectory = "/home/enzime";
      username = "enzime";
      extraModules = [ modules.work.hmModule ];
      extraSpecialArgs = {
        hostname = "zeta";
        using = { gnome = true; };
      };
    };
  };
}
