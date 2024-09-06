{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.nix-darwin.url = "github:LnL7/nix-darwin";
  inputs.nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.systems.url = "path:./flake.systems.nix";
  inputs.systems.flake = false;

  inputs.flake-compat.url = "github:nix-community/flake-compat";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
  inputs.flake-utils-plus.inputs.flake-utils.follows = "flake-utils";

  inputs.nix-overlay.url = "path:overlays/nix";
  inputs.nix-overlay.inputs.empty.follows = "";
  inputs.nix-overlay.inputs.flake-compat.follows = "flake-compat";
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
  inputs.git-hooks.inputs.flake-compat.follows = "flake-compat";
  inputs.git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  inputs.git-hooks.inputs.nixpkgs-stable.follows = "nixpkgs";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  inputs.nixos-apple-silicon.url =
    "github:Enzime/nixos-apple-silicon/refactor/peripheral-firmware";
  inputs.nixos-apple-silicon.inputs.flake-compat.follows = "flake-compat";
  inputs.nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";

  inputs.terranix.url = "github:terranix/terranix";
  inputs.terranix.inputs.bats-assert.follows = "";
  inputs.terranix.inputs.bats-support.follows = "";
  inputs.terranix.inputs.flake-utils.follows = "flake-utils";
  inputs.terranix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.terranix.inputs.terranix-examples.follows = "";

  inputs.nixos-anywhere.url =
    "github:Enzime/nixos-anywhere/fix/build-on-remote";
  inputs.nixos-anywhere.inputs.disko.follows = "disko";
  inputs.nixos-anywhere.inputs.flake-parts.follows = "flake-parts";
  inputs.nixos-anywhere.inputs.nixos-stable.follows = "";
  inputs.nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";

  inputs.impermanence.url = "github:nix-community/impermanence";

  nixConfig = {
    extra-substituters = [ "https://enzime.cachix.org" ];

    extra-trusted-public-keys = [
      "enzime.cachix.org-1:RvUdpEy6SEXlqvKYOVHpn5lNsJRsAZs6vVK1MFqJ9k4="
      "aether-1:fMOnq1aouEVTB6pz6TvszTrXQhrQAbPePlilPafmsHs="
      "chi-linux-builder-1:u0hwDFmxev8B65kKbSAjBP7nGR+it429j/UbsdZd3gs="
      "echo-1:B0HChd9IxG8P9V2NezeWCBsst8AdVTxesCiePZUaduc="
    ];
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, flake-utils-plus
    , agenix, disko, impermanence, flake-parts, git-hooks, terranix, ... }:

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

          pkgs' = import nixpkgs {
            system = "x86_64-linux";
            inherit (pkgs) config overlays;
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
            impermanence.nixosModules.home-manager.impermanence
            ./hosts/${host}/home.nix
          ] ++ homeModules;

          configRevision = {
            full = self.rev or self.dirtyRev or "dirty-inputs";
            short = self.shortRev or self.dirtyShortRev or "dirty-inputs";
          };

          keys = import ./keys.nix;

          extraHomeManagerArgs = {
            inherit inputs nixos configRevision keys moduleList;
          };
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
                impermanence.nixosModules.impermanence
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

          terraformConfigurations = if builtins.pathExists
          ./hosts/${host}/terraform-configuration.nix then {
            ${hostname} = terranix.lib.terranixConfiguration {
              system = "x86_64-linux";
              modules = [ ./hosts/${host}/terraform-configuration.nix ];
              extraArgs = { inherit inputs hostname; };
            };
          } else
            { };

          packages.x86_64-linux = if builtins.pathExists
          ./hosts/${host}/terraform-configuration.nix then {
            "${hostname}-apply" = pkgs'.writeShellApplication {
              name = "${hostname}-apply";
              runtimeInputs = [ self.packages.x86_64-linux.terraform ];
              text = ''
                if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
                cp ${self.terraformConfigurations.${hostname}} config.tf.json \
                  && terraform init \
                  && terraform apply
              '';
            };

            "${hostname}-destroy" = pkgs'.writeShellApplication {
              name = "${hostname}-destroy";
              runtimeInputs = [ self.packages.x86_64-linux.terraform ];
              text = ''
                if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
                cp ${self.terraformConfigurations.${hostname}} config.tf.json \
                  && terraform init \
                  && terraform destroy
              '';
            };
          } else
            { };
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
            bluetooth deluge duckdns nextcloud personal printers samba scanners
            sway wireless virt-manager;
        };
      }
      {
        host = "sigma";
        user = "enzime";
        system = "x86_64-linux";
        nixos = true;
        modules = builtins.attrNames {
          inherit (modules) impermanence laptop personal sway;
        };
      }
      {
        host = "echo";
        user = "enzime";
        system = "aarch64-darwin";
        modules = builtins.attrNames {
          inherit (modules) github-runner graphical-minimal;
        };
      }
      {
        host = "eris";
        user = "human";
        system = "x86_64-linux";
        nixos = true;
        modules =
          builtins.attrNames { inherit (modules) deluge reflector vncserver; };
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
          buildInputs = (builtins.attrValues {
            inherit (home-manager.packages.${system}) home-manager;
            inherit (agenix.packages.${system}) agenix;
            inherit (self'.packages) terraform;
          }) ++ config.pre-commit.settings.enabledPackages;

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
      };
      flake = { keys = import ./keys.nix; };
    });
}
