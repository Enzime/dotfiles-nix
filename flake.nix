{
  inputs.nixpkgs.url = github:Enzime/nixpkgs/localhost;

  inputs.nix-darwin.url = github:Enzime/nix-darwin/localhost;
  inputs.nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = github:nix-community/home-manager;
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.flake-utils-plus.url = github:gytis-ivaskevicius/flake-utils-plus;
  inputs.flake-utils-plus.inputs.flake-utils.follows = "flake-utils";

  inputs.nix-overlay.url = path:overlays/nix;
  inputs.nix-overlay.inputs.flake-utils.follows = "flake-utils";
  inputs.nix-overlay.inputs.nixpkgs.follows = "nixpkgs";

  inputs.agenix.url = github:ryantm/agenix;
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.firefox-addons-overlay.url = path:overlays/firefox-addons;
  inputs.firefox-addons-overlay.inputs.nixpkgs.follows = "nixpkgs";
  inputs.firefox-addons-overlay.inputs.flake-utils.follows = "flake-utils";

  inputs.deploy-rs.url = github:serokell/deploy-rs;
  inputs.deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  inputs.deploy-rs.inputs.utils.follows = "flake-utils";

  inputs.disko.url = github:nix-community/disko;
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, flake-utils, flake-utils-plus, agenix, deploy-rs, disko, ... }:

  let
    inherit (builtins) attrNames hasAttr filter getAttr readDir;
    inherit (nixpkgs.lib) concatMap filterAttrs foldr getAttrFromPath hasSuffix mapAttrs' mapAttrsToList mkIf nameValuePair optional recursiveUpdate removeSuffix unique;

    importFrom = path: filename: import (path + ("/" + filename));

    importOverlay = filename: _: importFrom ./overlays filename;
    regularOverlays = filterAttrs (name: _: hasSuffix ".nix" name) (readDir ./overlays);
    importedRegularOverlays = mapAttrsToList importOverlay regularOverlays;

    flakeOverlays = attrNames (filterAttrs (_: type: type == "directory") (readDir ./overlays));
    importedFlakeOverlays = map (name: getAttrFromPath [ "${name}-overlay" "overlay" ] inputs) flakeOverlays;

    modules = mapAttrs' (
      filename: _: nameValuePair
        (removeSuffix ".nix" filename)
        (importFrom ./modules filename)
    ) (readDir ./modules);

    modules' = modules;

    getModuleList = a: let
      imports = if (modules.${a} ? imports) then modules.${a}.imports else [];
    in if (imports == []) then [a] else [a] ++ unique (concatMap getModuleList imports);

    mkConfigurations = configs: foldr (recursiveUpdate) { } (map (mkConfiguration) configs);
    mkConfiguration = { host, hostSuffix ? if nixos then "-nixos" else "", user, system, nixos ? false, modules }:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = importedRegularOverlays ++ importedFlakeOverlays;
      };

      moduleList = unique (concatMap getModuleList ([ "base" ] ++ modules));
      modulesToImport = map (name: getAttr name modules') moduleList;

      hostname = "${host}${hostSuffix}";
      nixosModules = map (getAttr "nixosModule") (filter (hasAttr "nixosModule") modulesToImport);
      hmModules = map (getAttr "hmModule") (filter (hasAttr "hmModule") modulesToImport);
      darwinModules = map (getAttr "darwinModule") (filter (hasAttr "darwinModule") modulesToImport);
      home = [ ./hosts/${host}/home.nix ] ++ hmModules;

      configRevision = {
        full = self.rev or self.dirtyRev or "dirty-inputs";
        short = self.shortRev or self.dirtyShortRev or "dirty-inputs";
      };

      keys = import ./keys.nix;

      extraHomeManagerArgs = { inherit inputs nixos configRevision keys; };
    in {
      # nix build ~/.config/nixpkgs#nixosConfigurations.phi-nixos.config.system.build.toplevel
      # OR
      # nixos-rebuild build --flake ~/.config/nixpkgs#phi-nixos
      nixosConfigurations = if nixos then { ${hostname} = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          flake-utils-plus.nixosModules.autoGenFromInputs
          agenix.nixosModules.age
          ./hosts/${host}/configuration.nix
        ] ++ nixosModules ++ [
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;

            # `home-manager` uses `/etc/profiles/per-user/` instead of `~/.nix-profile`
            # Required for `fonts.fontconfig.enable = true;`
            home-manager.useUserPackages = true;

            home-manager.users.${user}.imports = home;
            home-manager.extraSpecialArgs = extraHomeManagerArgs;
          }
        ];
        specialArgs = { inherit inputs configRevision user host hostname keys; };
      }; } else { };

      # nix build ~/.config/nixpkgs#darwinConfigurations.chi.system
      # OR
      # darwin-rebuild build --flake ~/.config/nixpkgs#chi
      darwinConfigurations = if (hasSuffix "darwin" system) then { ${hostname} = nix-darwin.lib.darwinSystem {
        inherit system pkgs inputs;
        modules = [
          flake-utils-plus.darwinModules.autoGenFromInputs
          ./hosts/${host}/darwin-configuration.nix
        ] ++ darwinModules ++ [
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.${user}.imports = home;
            home-manager.extraSpecialArgs = extraHomeManagerArgs;
          }
        ];
        specialArgs = { inherit user hostname; };
      }; } else { };

      # nix build ~/.config/nixpkgs#homeConfigurations.enzime@phi-nixos.activationPackage
      # OR
      # home-manager build --flake ~/.config/nixpkgs#enzime@phi-nixos
      homeConfigurations."${user}@${hostname}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ({ ... }: {
            home.username = user;
            home.homeDirectory = if (hasSuffix "linux" system) then "/home/${user}" else "/Users/${user}";
          })
        ] ++ home;
        extraSpecialArgs = extraHomeManagerArgs;
      };

      deploy.nodes = if nixos then { ${hostname} = {
        hostname = host;
        sshUser = "root";

        profiles.system = {
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${hostname};
        };
      }; } else { };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
  in (mkConfigurations [
    {
      host = "chi";
      user = "enzime";
      system = "aarch64-darwin";
      modules = builtins.attrNames {
        inherit (modules) graphical;
      };
    }
    {
      host = "phi";
      user = "enzime";
      system = "x86_64-linux";
      nixos = true;
      modules = builtins.attrNames {
        inherit (modules) bluetooth duckdns gaming i3 nextcloud samba synergy-server sway wireless virt-manager x11vnc;
      };
    }
    {
      host = "sigma";
      user = "enzime";
      system = "x86_64-linux";
      nixos = true;
      modules = builtins.attrNames {
        inherit (modules) gnome i3 laptop personal sway;
      };
    }
    {
      host = "upsilon";
      user = "michael.hoang";
      system = "aarch64-darwin";
      modules = builtins.attrNames {
        inherit (modules) graphical laptop work;
      };
    }
    {
      host = "eris";
      hostSuffix = "";
      user = "human";
      system = "x86_64-linux";
      nixos = true;
      modules = builtins.attrNames {
        inherit (modules) i3 reflector vncserver;
      };
    }
  ]) // (
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = builtins.attrValues {
          inherit (pkgs) rnix-lsp;
          inherit (home-manager.packages.${system}) home-manager;
          inherit (agenix.packages.${system}) agenix;
          inherit (deploy-rs.packages.${system}) deploy-rs;
        };
      };
    })
  ) // ({
    nixConfig = {
      extra-substituters = [ "https://enzime.cachix.org" ];
      extra-trusted-public-keys = [
        "enzime.cachix.org-1:RvUdpEy6SEXlqvKYOVHpn5lNsJRsAZs6vVK1MFqJ9k4="
      ];
    };
  });
}
