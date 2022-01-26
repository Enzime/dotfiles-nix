{
  inputs.nixpkgs.url = github:Enzime/nixpkgs/localhost;

  inputs.home-manager.url = github:Enzime/home-manager/immutable-extensions-dir;
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.flake-utils-plus.url = github:gytis-ivaskevicius/flake-utils-plus;
  inputs.flake-utils-plus.inputs.flake-utils.follows = "flake-utils";

  inputs.nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.paperwm-overlay.url = path:overlays/paperwm;
  inputs.paperwm-overlay.inputs.flake-utils.follows = "flake-utils";
  inputs.paperwm-overlay.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nix-overlay.url = path:overlays/nix;
  inputs.nix-overlay.inputs.inheritedNix.follows = "nix";
  inputs.nix-overlay.inputs.flake-utils.follows = "flake-utils";
  inputs.nix-overlay.inputs.nixpkgs.follows = "nixpkgs";

  inputs.agenix.url = "github:ryantm/agenix";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixos-generators.url = "github:nix-community/nixos-generators";
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs@{ self, nix, nixpkgs, home-manager, flake-utils, flake-utils-plus, agenix, nixos-generators, ... }:

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
      home = [ ./hosts/${host}/home.nix ] ++ hmModules;

      configRevision = {
        full = if (self ? rev) then self.rev else if (self ? dirtyRev) then self.dirtyRev else "dirty-inputs";
        short = if (self ? rev) then self.shortRev else if (self ? dirtyRev) then self.dirtyShortRev else "dirty-inputs";
      };

      keys = import ./keys.nix;

      extraHomeManagerArgs = { inherit nixos configRevision; };
    in {
      # nix build ~/.config/nixpkgs#nixosConfigurations.phi-nixos.config.system.build.toplevel
      # OR
      # nixos-rebuild build --flake ~/.config/nixpkgs#phi-nixos
      nixosConfigurations = if nixos then { ${hostname} = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ({ ... }: {
            environment.systemPackages = [ home-manager.defaultPackage.${system} agenix.defaultPackage.${system} ];

            networking.hostName = hostname;

            # Generate `/etc/nix/inputs/<input>` and `/etc/nix/registry.json` using FUP
            nix.linkInputs = true;
            nix.generateNixPathFromInputs = true;
            nix.generateRegistryFromInputs = true;
          })
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
        # Required for `flake-utils-plus` to generate stuff
        specialArgs = { inherit inputs configRevision user host keys; };
      }; } else { };

      # nix build ~/.config/nixpkgs#homeConfigurations.enzime@phi-nixos.activationPackage
      # OR
      # home-manager build --flake ~/.config/nixpkgs#enzime@phi-nixos
      homeConfigurations."${user}@${hostname}" = home-manager.lib.homeManagerConfiguration {
        inherit system pkgs;
        configuration = { };
        homeDirectory = if (hasSuffix "linux" system) then "/home/${user}" else "/Users/${user}";
        username = user;
        extraModules = home;
        extraSpecialArgs = extraHomeManagerArgs;
      };
    };
  in (mkConfigurations [
    {
      host = "chi";
      user = "enzime";
      system = "aarch64-darwin";
      modules = [ ];
    }
    {
      host = "phi";
      user = "enzime";
      system = "x86_64-linux";
      nixos = true;
      modules = builtins.attrNames {
        inherit (modules) cosmic duckdns gaming i3 samba;
      };
    }
    {
      host = "sigma";
      user = "enzime";
      system = "x86_64-linux";
      nixos = true;
      modules = builtins.attrNames {
        inherit (modules) i3 laptop;
      };
    }
    {
      host = "tau";
      user = "enzime";
      system = "x86_64-linux";
      nixos = true;
      modules = builtins.attrNames {
        inherit (modules) cosmic i3 work laptop;
      };
    }
    {
      host = "zeta";
      user = "enzime";
      system = "x86_64-linux";
      nixos = true;
      modules = builtins.attrNames {
        inherit (modules) gnome work;
      };
    }
    {
      host = "apollo";
      hostSuffix = "";
      user = "human";
      system = "x86_64-linux";
      nixos = true;
      modules = builtins.attrNames { };
    }
    {
      host = "eris";
      hostSuffix = "";
      user = "human";
      system = "x86_64-linux";
      nixos = true;
      modules = builtins.attrNames {
        inherit (modules) i3;
      };
    }
  ]) // (
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system: {
      packages."nixosImages/bcachefs" = nixos-generators.nixosGenerate {
        pkgs = import nixpkgs { inherit system; };
        format = "install-iso";
        modules = [
          ({ modulesPath, pkgs, ... }: {
            imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix" ];
            boot.supportedFilesystems = [ "bcachefs" ];

            nix.extraOptions = (assert (builtins.compareVersions "2.5.1" pkgs.nix.version == 0); ''
              experimental-features = nix-command flakes
            '');
          })
          ((import ./modules/cachix.nix).nixosModule)
        ];
      };
    })
  );
}
