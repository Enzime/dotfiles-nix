{
  inputs.nixpkgs.url = "github:Enzime/nixpkgs/localhost";

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
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

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

  inputs.nixos-anywhere.url = "github:nix-community/nixos-anywhere";
  inputs.nixos-anywhere.inputs.disko.follows = "disko";
  inputs.nixos-anywhere.inputs.flake-parts.follows = "flake-parts";
  inputs.nixos-anywhere.inputs.nixos-stable.follows = "";
  inputs.nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-anywhere.inputs.treefmt-nix.follows = "";

  inputs.impermanence.url = "github:nix-community/impermanence";

  inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  inputs.clan-core.url = "git+https://git.clan.lol/clan/clan-core";
  inputs.clan-core.inputs.disko.follows = "disko";
  inputs.clan-core.inputs.flake-parts.follows = "flake-parts";
  inputs.clan-core.inputs.nixpkgs.follows = "nixpkgs";
  inputs.clan-core.inputs.systems.follows = "systems";
  # This causes a stack overflow when set to empty string
  inputs.clan-core.inputs.treefmt-nix.follows = "systems";

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, flake-utils-plus
    , agenix, disko, impermanence, nix-index-database, flake-parts, clan-core
    , git-hooks, terranix, ... }:

    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ clan-core.flakeModules.default git-hooks.flakeModule ];
      systems = import inputs.systems;

      clan = {
        meta.name = "Enzime";

        pkgsForSystem = system: nixpkgs.legacyPackages.${system};

        machines = builtins.mapAttrs (hostname: configuration: {
          imports = configuration._module.args.modules;

          config = { _module.args = configuration._module.specialArgs; };
        }) self.baseNixosConfigurations;
      };

      perSystem = { config, self', pkgs, lib, system, ... }:
        lib.mkMerge [
          {
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
              hooks.nixfmt-classic.enable = true;
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

            formatter = config.pre-commit.settings.hooks.nixfmt-classic.package;

            devShells.default = pkgs.mkShell {
              buildInputs = (builtins.attrValues {
                inherit (home-manager.packages.${system}) home-manager;
                inherit (agenix.packages.${system}) agenix;
                inherit (clan-core.packages.${system}) clan-cli;
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

            packages.add-subflakes-to-store = pkgs.writeShellApplication {
              name = "add-subflakes-to-store";
              runtimeInputs = builtins.attrValues {
                inherit (pkgs) nix git findutils gnused;
              };
              text = ''
                set -x

                # This gets set when nix-shell --pure is used
                if [[ "''${NIX_SSL_CERT_FILE:-}" == "/no-cert-file.crt" ]]; then
                  export NIX_SSL_CERT_FILE=
                fi

                cp flake.lock flake.lock.old

                # shellcheck disable=SC2046
                nix flake update systems $(find overlays -mindepth 1 -type d -exec basename {} \; | sed -E 's/^(.*)$/&-overlay/' | paste -sd ' ' -)

                mv flake.lock.old flake.lock
              '';
            };

            packages.check = pkgs.writeShellApplication {
              name = "nix-flake-check-without-ifd";
              runtimeInputs =
                builtins.attrValues { inherit (pkgs) patch nix jq; };
              text = ''
                set -x

                nix flake check ${
                  pkgs.stdenvNoCC.mkDerivation {
                    name = "patched-self";
                    # WORKAROUND: `toString ./.` works on macOS but not Linux
                    src = toString self;
                    patches = [ ./files/no-ifd.diff ];
                    installPhase = "cp -r . $out";
                  }
                } "$@"
              '';
            };

            packages.terraform = pkgs.terraform.withPlugins (p:
              builtins.attrValues {
                inherit (p) external hcloud local null onepassword tailscale;
              });
          }
          {
            packages = let
              vmWithNewHostPlatform = name:
                pkgs.writeShellApplication {
                  name = "run-${name}-vm-on-${system}";
                  runtimeInputs = builtins.attrValues { inherit (pkgs) jq; };
                  text = ''
                    set -x

                    drv="$(nix eval --raw ${self}#nixosConfigurations.${name} \
                      --apply 'original:
                        let configuration = original.extendModules { modules = [ ({ lib, ... }: {
                          _file = "<nixos-rebuild build-vm override>";
                          nixpkgs.hostPlatform = lib.mkForce "${system}";
                        }) ]; };
                        in configuration.config.system.build.vm.drvPath' )"
                    vm=$(nix build --no-link "$drv^*" --json | jq -r '.[0].outputs.out')
                    # shellcheck disable=SC2211
                    "$vm"/bin/run-*-vm
                  '';
                };
            in lib.mapAttrs' (hostname: configuration:
              lib.nameValuePair "${hostname}-vm"
              (vmWithNewHostPlatform hostname)) self.nixosConfigurations;
          }
          {
            packages = let
              deploy = hostname: configuration:
                pkgs.writeShellApplication {
                  name = "deploy-${hostname}-from-${system}";
                  runtimeInputs = builtins.attrValues { inherit (pkgs) jq; };
                  text = let
                    cfg = configuration.config;

                    user = configuration._module.specialArgs.user;
                    dest = configuration._module.specialArgs.hostname;
                    darwin-rebuild = cfg.system.build.darwin-rebuild;
                  in ''
                    flags=()
                    overriddenInputs=()

                    while [ $# -gt 0 ]; do
                      flag=$1; shift 1
                      if [[ $flag == "--override-input" ]]; then
                        arg1=$1; shift 1
                        arg2=$1; shift 1
                        resolved=$(nix flake metadata "$arg2" --json | jq -r '.path')
                        flags+=("--override-input" "$arg1" "$resolved")
                        overriddenInputs+=("$resolved")
                      fi
                    done

                    if [[ $(hostname) != "${hostname}" || $USER != "${user}" ]]; then
                      nix copy --to ssh-ng://root@${dest} ${
                        ./.
                      } "''${overriddenInputs[@]}"
                      ssh -t ${user}@${dest} nix run \
                        ${
                          ./.
                        }#darwinConfigurations.${hostname}.config.system.build.darwin-rebuild \
                        "''${flags[@]}" \
                        switch \
                        -- \
                        --flake ${./.} \
                        "''${flags[@]}"

                    ${lib.optionalString
                    (system == configuration.pkgs.hostPlatform.system) ''
                      else
                        ${lib.getExe darwin-rebuild} switch --flake ${
                          ./.
                        } "''${flags[@]}"
                    ''}
                    fi
                  '';
                };
            in lib.mapAttrs' (hostname: configuration:
              lib.nameValuePair "deploy-${hostname}"
              (deploy hostname configuration)) self.darwinConfigurations;
          }
        ];
      flake = (let
        inherit (builtins) attrNames hasAttr filter getAttr readDir;
        inherit (nixpkgs.lib)
          concatMap filterAttrs foldr getAttrFromPath hasSuffix mapAttrs'
          mapAttrsToList nameValuePair optionals optionalAttrs recursiveUpdate
          removeSuffix unique;

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
        mkConfiguration = { host, hostSuffix ? "", user, system
          , nixos ? hasSuffix "linux" system, modules, clan ? false }:
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

            moduleList = unique (concatMap getModuleList
              ([ "base" ] ++ modules ++ optionals clan [ "clan" ]));
            modulesToImport = map (name: getAttr name modules') moduleList;

            hostname = "${host}${hostSuffix}";
            nixosModules = map (getAttr "nixosModule")
              (filter (hasAttr "nixosModule") modulesToImport);
            homeModules = map (getAttr "homeModule")
              (filter (hasAttr "homeModule") modulesToImport);
            darwinModules = map (getAttr "darwinModule")
              (filter (hasAttr "darwinModule") modulesToImport);
            home = [
              nix-index-database.hmModules.nix-index
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

            nixosConfigurationsKey =
              if clan then "baseNixosConfigurations" else "nixosConfigurations";
          in {
            # nix build ~/.config/home-manager#nixosConfigurations.phi-nixos.config.system.build.toplevel
            # OR
            # nixos-rebuild build --flake ~/.config/home-manager#phi-nixos
            ${nixosConfigurationsKey} = optionalAttrs nixos {
              ${hostname} = nixpkgs.lib.nixosSystem {
                modules = [
                  {
                    nixpkgs = {
                      inherit (pkgs) config overlays;
                      hostPlatform = system;
                    };
                  }
                  flake-utils-plus.nixosModules.autoGenFromInputs
                  agenix.nixosModules.age
                  disko.nixosModules.disko
                  impermanence.nixosModules.impermanence
                  nix-index-database.nixosModules.nix-index
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
            };

            # nix build ~/.config/home-manager#darwinConfigurations.chi.system
            # OR
            # darwin-rebuild build --flake ~/.config/home-manager#chi
            darwinConfigurations =
              optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
                ${hostname} = nix-darwin.lib.darwinSystem {
                  inherit system pkgs inputs;
                  modules = [
                    flake-utils-plus.darwinModules.autoGenFromInputs
                    agenix.darwinModules.age
                    nix-index-database.darwinModules.nix-index
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
                  specialArgs = {
                    inherit configRevision user host hostname keys;
                  };
                };
              };

            # nix build ~/.config/home-manager#homeConfigurations.enzime@phi-nixos.activationPackage
            # OR
            # home-manager build --flake ~/.config/home-manager#enzime@phi-nixos
            homeConfigurations."${user}@${hostname}" =
              home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [({
                  home.username = user;
                  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then
                    "/Users/${user}"
                  else
                    "/home/${user}";
                })] ++ home;
                extraSpecialArgs = extraHomeManagerArgs;
              };

            terraformConfigurations = optionalAttrs (builtins.pathExists
              ./hosts/${host}/terraform-configuration.nix) {
                ${hostname} = terranix.lib.terranixConfiguration {
                  system = "x86_64-linux";
                  modules = [ ./hosts/${host}/terraform-configuration.nix ];
                  extraArgs = { inherit inputs hostname keys; };
                };
              };

            packages.x86_64-linux = optionalAttrs (builtins.pathExists
              ./hosts/${host}/terraform-configuration.nix) {
                "${hostname}-apply" = pkgs'.writeShellApplication {
                  name = "${hostname}-apply";
                  runtimeInputs = [ self.packages.x86_64-linux.terraform ];
                  text = ''
                    if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
                    cp ${
                      self.terraformConfigurations.${hostname}
                    } config.tf.json \
                      && terraform init \
                      && terraform apply
                  '';
                };

                "${hostname}-destroy" = pkgs'.writeShellApplication {
                  name = "${hostname}-destroy";
                  runtimeInputs = [ self.packages.x86_64-linux.terraform ];
                  text = ''
                    if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
                    cp ${
                      self.terraformConfigurations.${hostname}
                    } config.tf.json \
                      && terraform init \
                      && terraform destroy
                  '';
                };
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
            inherit (modules) android laptop linux-builder personal;
          };
        }
        {
          host = "hermes";
          hostSuffix = "-nixos";
          user = "enzime";
          system = "aarch64-linux";
          modules =
            builtins.attrNames { inherit (modules) laptop personal sway; };
        }
        {
          host = "phi";
          hostSuffix = "-nixos";
          user = "enzime";
          system = "x86_64-linux";
          clan = true;
          modules = builtins.attrNames {
            inherit (modules)
              android bluetooth deluge nextcloud personal printers samba
              scanners sway wireless virt-manager;
          };
        }
        {
          host = "sigma";
          user = "enzime";
          system = "x86_64-linux";
          clan = true;
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
          modules = builtins.attrNames {
            inherit (modules) deluge reflector vncserver;
          };
        }
        {
          host = "aether";
          user = "enzime";
          system = "aarch64-linux";
          modules = [ ];
        }
      ]));
    };
}
