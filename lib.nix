{ lib }:
let
  inherit (builtins) readDir;
  inherit (lib)
    attrNames concatMap filter filterAttrs getAttr getAttrFromPath hasAttr
    hasSuffix mapAttrs' mapAttrsToList nameValuePair optionalAttrs removeSuffix
    unique;
  inherit (lib.path) removePrefix;

  importFrom = path: filename: import (path + ("/" + filename));

  pathTo = path: ./. + "/${removePrefix ./. path}";

  importOverlay = filename: _: importFrom (pathTo ./overlays) filename;
  regularOverlays =
    filterAttrs (name: _: hasSuffix ".nix" name) (readDir (pathTo ./overlays));
  importedRegularOverlays = mapAttrsToList importOverlay regularOverlays;

  modules' = mapAttrs' (filename: _:
    nameValuePair (removeSuffix ".nix" filename)
    (importFrom (pathTo ./modules) filename))
    (filterAttrs (_: type: type == "regular") (readDir (pathTo ./modules)));

  getModuleList = a:
    let
      imports =
        if (modules'.${a} ? imports) then modules'.${a}.imports else [ ];
    in if (imports == [ ]) then
      [ a ]
    else
      [ a ] ++ unique (concatMap getModuleList imports);

  mkConfiguration = { host, hostSuffix ? "", user, system
    , nixos ? hasSuffix "linux" system, modules, tags ? [ ] }:
    { self, inputs, lib, ... }:
    let
      flakeOverlays = attrNames (filterAttrs (_: type: type == "directory")
        (readDir (pathTo ./overlays)));
      importedFlakeOverlays =
        map (name: getAttrFromPath [ "${name}-overlay" "overlay" ] inputs)
        flakeOverlays;

      nixpkgs = {
        config.allowUnfree = true;
        overlays = importedRegularOverlays ++ importedFlakeOverlays;
        hostPlatform = system;
      };

      isDarwin = hasSuffix "darwin" system;

      moduleList = unique (concatMap getModuleList ([ "base" ] ++ modules));
      modulesToImport = map (name: getAttr name modules') moduleList;

      hostname = "${host}${hostSuffix}";
      nixosModules = map (getAttr "nixosModule")
        (filter (hasAttr "nixosModule") modulesToImport);
      homeModules = map (getAttr "homeModule")
        (filter (hasAttr "homeModule") modulesToImport);
      darwinModules = map (getAttr "darwinModule")
        (filter (hasAttr "darwinModule") modulesToImport);
      home = [
        inputs.nix-index-database.homeModules.nix-index
        (pathTo ./hosts/${host}/home.nix)
      ] ++ homeModules;

      configRevision = {
        full = self.rev or self.dirtyRev or "dirty-inputs";
        short = self.shortRev or self.dirtyShortRev or "dirty-inputs";
      };

      keys = import (pathTo ./keys.nix);

      extraHomeManagerArgs = { inherit inputs configRevision keys moduleList; };
    in {
      imports = [{
        clan = optionalAttrs (builtins.length tags > 0) {
          inventory.machines.${hostname}.tags = tags;
        };
      }];

      clan = optionalAttrs nixos {
        inventory.instances.primary-user-password.roles.default.machines.${hostname}.settings =
          {
            inherit user;
          };
      };

      # nix build ~/.config/home-manager#nixosConfigurations.phi-nixos.config.system.build.toplevel
      # OR
      # nixos-rebuild build --flake ~/.config/home-manager#phi-nixos
      flake.baseNixosConfigurations = optionalAttrs nixos {
        ${hostname} = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            { inherit nixpkgs; }
            inputs.flake-utils-plus.nixosModules.autoGenFromInputs
            inputs.disko.nixosModules.disko
            inputs.preservation.nixosModules.preservation
            inputs.nix-index-database.nixosModules.nix-index
            inputs.hoopsnake.nixosModules.default
            (pathTo ./hosts/${host}/configuration.nix)
            ({ options, ... }: {
              config = lib.optionalAttrs (options ? facter) {
                facter.reportPath = lib.mkIf
                  (builtins.pathExists (pathTo ./hosts/${host}/facter.json))
                  (lib.mkForce (pathTo ./hosts/${host}/facter.json));
              };
            })
          ] ++ nixosModules ++ [
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;

              # `home-manager` uses `/etc/profiles/per-user/` instead of `~/.nix-profile`
              # Required for `fonts.fontconfig.enable = true;`
              home-manager.useUserPackages = true;

              home-manager.users.${user}.imports = home;
              home-manager.extraSpecialArgs = extraHomeManagerArgs;
            }
          ];
          specialArgs = {
            inherit inputs configRevision user host hostname keys;
          };
        };
      };

      # nix build ~/.config/home-manager#darwinConfigurations.hyperion-macos.system
      # OR
      # darwin-rebuild build --flake ~/.config/home-manager#hyperion-macos
      flake.baseDarwinConfigurations = optionalAttrs isDarwin {
        ${hostname} = inputs.nix-darwin.lib.darwinSystem {
          inherit inputs;
          modules = [
            { inherit nixpkgs; }
            inputs.flake-utils-plus.darwinModules.autoGenFromInputs
            inputs.nix-index-database.darwinModules.nix-index
            (pathTo ./hosts/${host}/darwin-configuration.nix)
          ] ++ darwinModules ++ [
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.${user}.imports = home;
              home-manager.extraSpecialArgs = extraHomeManagerArgs;
            }
          ];
          specialArgs = { inherit configRevision user host hostname keys; };
        };
      };

      # nix build ~/.config/home-manager#homeConfigurations.enzime@phi-nixos.activationPackage
      # OR
      # home-manager build --flake ~/.config/home-manager#enzime@phi-nixos
      flake.homeConfigurations."${user}@${hostname}" =
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            inherit (nixpkgs) config overlays;
            system = nixpkgs.hostPlatform;
          };
          modules = [
            ({ pkgs, ... }: {
              home.username = user;
              home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then
                "/Users/${user}"
              else
                "/home/${user}";
            })
          ] ++ home;
          extraSpecialArgs = extraHomeManagerArgs;
        };

      flake.checks.${system} = (optionalAttrs nixos {
        "nixos-${hostname}" =
          self.nixosConfigurations.${hostname}.config.system.build.toplevel;
      }) // (optionalAttrs isDarwin {
        "nix-darwin-${hostname}" =
          self.darwinConfigurations.${hostname}.config.system.build.toplevel;
      }) // {
        "home-manager-${user}@${hostname}" =
          self.homeConfigurations."${user}@${hostname}".activationPackage;
      };

      flake.terranixModules = optionalAttrs (builtins.pathExists
        (pathTo ./hosts/${host}/terraform-configuration.nix)) {
          ${hostname}.imports = [
            (pathTo ./modules/terranix/base.nix)
            (inputs.flake-parts.lib.importApply
              (pathTo ./hosts/${host}/terraform-configuration.nix) {
                inherit host hostname keys;
              })
          ];

          everything.imports = [ self.terranixModules.${hostname} ];
        };
    };
in {
  inherit mkConfiguration pathTo;
  modules = modules';
}
