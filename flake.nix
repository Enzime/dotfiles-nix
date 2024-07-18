{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.nix-darwin.url = "github:LnL7/nix-darwin";
  inputs.nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.systems.url = "path:./flake.systems.nix";
  inputs.systems.flake = false;

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
  inputs.flake-utils-plus.inputs.flake-utils.follows = "flake-utils";

  inputs.nix-overlay.url = "path:overlays/nix";
  inputs.nix-overlay.inputs.flake-parts.follows = "flake-parts";
  inputs.nix-overlay.inputs.flake-utils.follows = "flake-utils";
  inputs.nix-overlay.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix-overlay.inputs.git-hooks.follows = "git-hooks";

  inputs.agenix.url = "github:ryantm/agenix";
  inputs.agenix.inputs.darwin.follows = "nix-darwin";
  inputs.agenix.inputs.home-manager.follows = "home-manager";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.agenix.inputs.systems.follows = "systems";

  inputs.firefox-addons-overlay.url = "path:overlays/firefox-addons";
  inputs.firefox-addons-overlay.inputs.nixpkgs.follows = "nixpkgs";
  inputs.firefox-addons-overlay.inputs.flake-utils.follows = "flake-utils";

  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.git-hooks.url = "github:cachix/git-hooks.nix";
  inputs.git-hooks.inputs.flake-compat.follows = "nix-overlay/nix/flake-compat";
  inputs.git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  inputs.git-hooks.inputs.nixpkgs-stable.follows = "nixpkgs";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  inputs.nixos-apple-silicon.url =
    "github:Enzime/nixos-apple-silicon/refactor/peripheral-firmware";
  inputs.nixos-apple-silicon.inputs.flake-compat.follows =
    "nix-overlay/nix/flake-compat";
  inputs.nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";

  inputs.terranix.url = "github:terranix/terranix";
  inputs.terranix.inputs.flake-utils.follows = "flake-utils";
  inputs.terranix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixos-anywhere.url =
    "github:Enzime/nixos-anywhere/fix/terraform-install";
  inputs.nixos-anywhere.inputs.disko.follows = "disko";
  inputs.nixos-anywhere.inputs.flake-parts.follows = "flake-parts";
  inputs.nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, flake-utils-plus
    , agenix, disko, git-hooks, flake-parts, terranix, ... }:

    nixpkgs.lib.recursiveUpdate

    (let
      inherit (builtins) attrNames hasAttr filter getAttr readDir;
      inherit (nixpkgs.lib)
        concatMap filterAttrs foldr getAttrFromPath hasSuffix mapAttrs'
        mapAttrsToList nameValuePair recursiveUpdate removeSuffix unique;

      importFrom = path: filename: import (path + ("/" + filename));

      importOverlay = filename: _: importFrom ./overlays filename;
      regularOverlays =
        filterAttrs (name: _: hasSuffix ".nix" name) (readDir ./overlays);
      importedRegularOverlays = mapAttrsToList importOverlay regularOverlays;

      flakeOverlays = attrNames
        (filterAttrs (_: type: type == "directory") (readDir ./overlays));
      importedFlakeOverlays =
        map (name: getAttrFromPath [ "${name}-overlay" "overlay" ] inputs)
        flakeOverlays;

      modules = mapAttrs' (filename: _:
        nameValuePair (removeSuffix ".nix" filename)
        (importFrom ./modules filename)) (readDir ./modules);

      modules' = modules;

      getModuleList = a:
        let
          imports =
            if (modules.${a} ? imports) then modules.${a}.imports else [ ];
        in if (imports == [ ]) then
          [ a ]
        else
          [ a ] ++ unique (concatMap getModuleList imports);

      mkConfigurations = configs:
        foldr (recursiveUpdate) { } (map (mkConfiguration) configs);
      mkConfiguration =
        { host, hostSuffix ? "", user, system, nixos ? false, modules }:
        let
          pkgs = import nixpkgs {
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
          home = [ ./hosts/${host}/home.nix ] ++ homeModules;

          configRevision = {
            full = self.rev or self.dirtyRev or "dirty-inputs";
            short = self.shortRev or self.dirtyShortRev or "dirty-inputs";
          };

          keys = import ./keys.nix;

          extraHomeManagerArgs = { inherit inputs nixos configRevision keys; };
        in {
          # nix build ~/.config/home-manager#nixosConfigurations.phi-nixos.config.system.build.toplevel
          # OR
          # nixos-rebuild build --flake ~/.config/home-manager#phi-nixos
          nixosConfigurations = if nixos then {
            ${hostname} = nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                { nixpkgs = { inherit (pkgs) config overlays; }; }
                flake-utils-plus.nixosModules.autoGenFromInputs
                agenix.nixosModules.age
                disko.nixosModules.disko
                ./hosts/${host}/configuration.nix
              ] ++ nixosModules ++ [
                home-manager.nixosModules.home-manager
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
          } else
            { };

          # nix build ~/.config/home-manager#darwinConfigurations.chi.system
          # OR
          # darwin-rebuild build --flake ~/.config/home-manager#chi
          darwinConfigurations = if (hasSuffix "darwin" system) then {
            ${hostname} = nix-darwin.lib.darwinSystem {
              inherit system pkgs inputs;
              modules = [
                flake-utils-plus.darwinModules.autoGenFromInputs
                agenix.darwinModules.age
                ./hosts/${host}/darwin-configuration.nix
              ] ++ darwinModules ++ [
                home-manager.darwinModules.home-manager
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;

                  home-manager.users.${user}.imports = home;
                  home-manager.extraSpecialArgs = extraHomeManagerArgs;
                }
              ];
              specialArgs = { inherit configRevision user host hostname keys; };
            };
          } else
            { };

          # nix build ~/.config/home-manager#homeConfigurations.enzime@phi-nixos.activationPackage
          # OR
          # home-manager build --flake ~/.config/home-manager#enzime@phi-nixos
          homeConfigurations."${user}@${hostname}" =
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [({
                home.username = user;
                home.homeDirectory = if (hasSuffix "linux" system) then
                  "/home/${user}"
                else
                  "/Users/${user}";
              })] ++ home;
              extraSpecialArgs = extraHomeManagerArgs;
            };
        };
    in (mkConfigurations [
      {
        host = "chi";
        user = "enzime";
        system = "aarch64-darwin";
        modules =
          builtins.attrNames { inherit (modules) linux-builder personal; };
      }
      {
        host = "hermes";
        hostSuffix = "-macos";
        user = "enzime";
        system = "aarch64-darwin";
        modules = builtins.attrNames {
          inherit (modules) laptop linux-builder personal;
        };
      }
      {
        host = "hermes";
        hostSuffix = "-nixos";
        user = "enzime";
        system = "aarch64-linux";
        nixos = true;
        modules =
          builtins.attrNames { inherit (modules) laptop personal sway; };
      }
      {
        host = "phi";
        hostSuffix = "-nixos";
        user = "enzime";
        system = "x86_64-linux";
        nixos = true;
        modules = builtins.attrNames {
          inherit (modules)
            bluetooth duckdns gaming nextcloud printers samba scanners sway
            syncthing wireless virt-manager;
        };
      }
      {
        host = "sigma";
        user = "enzime";
        system = "x86_64-linux";
        nixos = true;
        modules =
          builtins.attrNames { inherit (modules) laptop personal sway; };
      }
      {
        host = "echo";
        user = "builder";
        system = "aarch64-darwin";
        modules = builtins.attrNames { inherit (modules) graphical-minimal; };
      }
      {
        host = "eris";
        user = "human";
        system = "x86_64-linux";
        nixos = true;
        modules = builtins.attrNames { inherit (modules) reflector vncserver; };
      }
      {
        host = "aether";
        user = "enzime";
        system = "aarch64-linux";
        nixos = true;
        modules = [ ];
      }
    ]))

    (flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ git-hooks.flakeModule ];
      systems = import inputs.systems;
      perSystem = { config, self', pkgs, system, ... }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            (import ./overlays/identify.nix)
            (import ./overlays/terraform.nix)
            (inputs.nix-overlay.outputs.overlay)
          ];
        };

        pre-commit.settings = {
          src = ./.;
          hooks.nixfmt.enable = true;
          hooks.nil.enable = true;
          hooks.shellcheck.enable = true;

          hooks.no-todo = {
            enable = true;
            name = "no TODOs";
            entry = "${./files/no-todos}";
            language = "system";
            pass_filenames = false;
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = builtins.attrValues {
            inherit (home-manager.packages.${system}) home-manager;
            inherit (agenix.packages.${system}) agenix;
            inherit (pkgs) pre-commit;
            inherit (self'.packages) terraform;
          };

          shellHook = ''
            POST_CHECKOUT_HOOK=$(git rev-parse --git-common-dir)/hooks/post-checkout
            TMPFILE=$(mktemp)
            if curl -o $TMPFILE --fail https://raw.githubusercontent.com/Enzime/dotfiles-nix/HEAD/files/post-checkout; then
              if [[ -e $POST_CHECKOUT_HOOK ]]; then
                echo "Removing existing $POST_CHECKOUT_HOOK"
                rm $POST_CHECKOUT_HOOK
              fi
              echo "Replacing $POST_CHECKOUT_HOOK with $TMPFILE"
              cp $TMPFILE $POST_CHECKOUT_HOOK
              chmod a+x $POST_CHECKOUT_HOOK
            fi

            if [[ -e $POST_CHECKOUT_HOOK ]]; then
              $POST_CHECKOUT_HOOK
            fi

            ${config.pre-commit.devShell.shellHook}
          '';
        };

        packages.terraform = pkgs.terraform.withPlugins (p:
          builtins.attrValues {
            inherit (p) external hcloud local null onepassword tailscale;
          });

        packages."aether-apply" = pkgs.writeShellApplication {
          name = "aether-apply";
          runtimeInputs = [ self'.packages.terraform ];
          text = ''
            if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
            cp ${self.terraformConfigurations.aether} config.tf.json \
              && terraform init \
              && terraform apply
          '';
        };

        packages."aether-destroy" = pkgs.writeShellApplication {
          name = "aether-destroy";
          runtimeInputs = [ self'.packages.terraform ];
          text = ''
            if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
            cp ${self.terraformConfigurations.aether} config.tf.json \
              && terraform init \
              && terraform destroy
          '';
        };
      };
      flake = {
        keys = import ./keys.nix;

        nixConfig = {
          extra-substituters = [ "https://enzime.cachix.org" ];
          extra-trusted-public-keys = builtins.attrValues {
            inherit (self.keys.signing) aether chi-linux-builder;

            "enzime.cachix.org" = self.keys.signing."enzime.cachix.org";
          };
        };

        terraformConfigurations.aether = terranix.lib.terranixConfiguration {
          system = "x86_64-linux";
          modules = [ ./hosts/aether/terraform-configuration.nix ];
          extraArgs = { inherit inputs; };
        };
      };
    });
}
