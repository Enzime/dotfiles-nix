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
    , nixos ? hasSuffix "linux" system, modules }:
    { self, inputs, lib, ... }:
    let
      flakeOverlays = attrNames (filterAttrs (_: type: type == "directory")
        (readDir (pathTo ./overlays)));
      importedFlakeOverlays =
        map (name: getAttrFromPath [ "${name}-overlay" "overlay" ] inputs)
        flakeOverlays;

      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = importedRegularOverlays ++ importedFlakeOverlays;
      };

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
        inputs.nix-index-database.hmModules.nix-index
        inputs.impermanence.nixosModules.home-manager.impermanence
        (pathTo ./hosts/${host}/home.nix)
      ] ++ homeModules;

      configRevision = {
        full = self.rev or self.dirtyRev or "dirty-inputs";
        short = self.shortRev or self.dirtyShortRev or "dirty-inputs";
      };

      keys = import (pathTo ./keys.nix);

      extraHomeManagerArgs = { inherit inputs configRevision keys moduleList; };
    in {
      # nix build ~/.config/home-manager#nixosConfigurations.phi-nixos.config.system.build.toplevel
      # OR
      # nixos-rebuild build --flake ~/.config/home-manager#phi-nixos
      flake.baseNixosConfigurations = optionalAttrs nixos {
        ${hostname} = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            {
              nixpkgs = {
                inherit (pkgs) config overlays;
                hostPlatform = system;
              };
            }
            inputs.flake-utils-plus.nixosModules.autoGenFromInputs
            inputs.agenix.nixosModules.age
            inputs.disko.nixosModules.disko
            inputs.impermanence.nixosModules.impermanence
            inputs.nix-index-database.nixosModules.nix-index
            (pathTo ./hosts/${host}/configuration.nix)
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
      flake.baseDarwinConfigurations =
        optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          ${hostname} = inputs.nix-darwin.lib.darwinSystem {
            inherit system pkgs inputs;
            modules = [
              inputs.flake-utils-plus.darwinModules.autoGenFromInputs
              inputs.agenix.darwinModules.age
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
          inherit pkgs;
          modules = [{
            home.username = user;
            home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then
              "/Users/${user}"
            else
              "/home/${user}";
          }] ++ home;
          extraSpecialArgs = extraHomeManagerArgs;
        };

      flake.checks.${system} = (optionalAttrs nixos {
        "nixos-${hostname}" =
          self.nixosConfigurations.${hostname}.config.system.build.toplevel;
      }) // (optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        "nix-darwin-${hostname}" =
          self.darwinConfigurations.${hostname}.config.system.build.toplevel;
      }) // {
        "home-manager-${user}@${hostname}" =
          self.homeConfigurations."${user}@${hostname}".activationPackage;
      };

      perSystem = { system, self', pkgs, ... }: {
        terraformConfigurations = optionalAttrs (builtins.pathExists
          (pathTo ./hosts/${host}/terraform-configuration.nix)) {
            ${hostname} = inputs.terranix.lib.terranixConfiguration {
              inherit system;
              modules =
                [ (pathTo ./hosts/${host}/terraform-configuration.nix) ];
              extraArgs = { inherit inputs hostname keys; };
            };
          };

        packages = optionalAttrs (builtins.pathExists
          (pathTo ./hosts/${host}/terraform-configuration.nix)) (let
            inherit (self'.packages) terraform;
            inherit (terraform.meta) mainProgram;
          in {
            "${hostname}-apply" = pkgs.writeShellApplication {
              name = "${hostname}-apply";
              runtimeInputs = [ terraform ];
              text = ''
                if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
                cp ${self'.terraformConfigurations.${hostname}} config.tf.json \
                  && ${mainProgram} init \
                  && ${mainProgram} apply
              '';
            };

            "${hostname}-destroy" = pkgs.writeShellApplication {
              name = "${hostname}-destroy";
              runtimeInputs = [ terraform ];
              text = ''
                if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
                cp ${self'.terraformConfigurations.${hostname}} config.tf.json \
                  && ${mainProgram} init \
                  && ${mainProgram} destroy
              '';
            };
          });
      };
    };
in {
  inherit mkConfiguration;
  modules = modules';
}
