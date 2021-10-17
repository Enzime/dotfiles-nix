{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  inputs.home-manager.url = github:nix-community/home-manager;
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-utils-plus.url = github:gytis-ivaskevicius/flake-utils-plus;
  inputs."overlays/paperwm".url = path:overlays/paperwm;
  inputs."overlays/paperwm".inputs.flake-utils.follows = "flake-utils-plus/flake-utils";
  inputs."overlays/paperwm".inputs.nixpkgs.follows = "nixpkgs";
  inputs."overlays/nix".url = path:overlays/nix;
  inputs."overlays/nix".inputs.inheritedNix.follows = "nix";
  inputs."overlays/nix".inputs.flake-utils.follows = "flake-utils-plus/flake-utils";
  inputs."overlays/nix".inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs@{ self, nix, nixpkgs, home-manager, flake-utils-plus, ... }:

  let
    inherit (builtins) attrNames hasAttr filter getAttr readDir;
    inherit (nixpkgs.lib) attrValues foldr filterAttrs getAttrFromPath hasSuffix mapAttrs' mapAttrsToList mkIf nameValuePair recursiveUpdate removeSuffix;

    importFrom = path: filename: import (path + ("/" + filename));

    importOverlay = filename: _: importFrom ./overlays filename;
    regularOverlays = filterAttrs (name: _: hasSuffix ".nix" name) (readDir ./overlays);
    importedRegularOverlays = mapAttrsToList importOverlay regularOverlays;

    flakeOverlays = attrNames (filterAttrs (_: type: type == "directory") (readDir ./overlays));
    importedFlakeOverlays = map (name: getAttrFromPath [ "overlays/${name}" "overlay" ] inputs) flakeOverlays;

    patches = let
      inherit (import nixpkgs { system = "x86_64-linux"; }) fetchpatch;
    in [
      (fetchpatch {
        name = "samba-open-firewall-ports-by-default.patch";
        url = "https://github.com/NixOS/nixpkgs/commit/4f704e88b8c37d4514dc0a669986bc47ac2e86f0.patch";
        sha256 = "sha256-EipMNHcqZitoGURYogz5u1AESSWld/ET4DdGzuVNWqE=";
      })
      # Fixes building Steam
      (fetchpatch {
        name = "tracker-patch-failing-test-due-to-float-comparison.patch";
        url = "https://github.com/NixOS/nixpkgs/commit/b0ed9c8372686a513c947c204956e7a28e7e7147.patch";
        sha256 = "sha256-j/cs4wK1twKSGHFoWtZI1g1IdWqVO0Dt6vSaADB64eo=";
      })
    ];

    patchedNixpkgs = flake-utils-plus.lib.patchChannel "x86_64-linux" nixpkgs patches;

    pkgs = import patchedNixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      overlays = importedRegularOverlays ++ importedFlakeOverlays;
    };

    modules = mapAttrs' (
      filename: _: nameValuePair
        (removeSuffix ".nix" filename)
        (importFrom ./modules filename)
    ) (readDir ./modules);

    mkConfigurations = configs: foldr (recursiveUpdate) { } (map (mkConfiguration) configs);
    mkConfiguration = { host, hostSuffix ? "-nixos", user, system, nixos ? false, modules }:
    let
      hostname = "${host}${hostSuffix}";
      nixosModules = map (getAttr "nixosModule") (filter (hasAttr "nixosModule") modules);
      hmModules = map (getAttr "hmModule") (filter (hasAttr "hmModule") modules);
      home = [ ./home.nix ./hosts/${host}/home.nix ] ++ hmModules;

      configRevision = {
        full = if (self ? rev) then self.rev else if (self ? dirtyRev) then self.dirtyRev else "dirty-inputs";
        short = if (self ? rev) then self.shortRev else if (self ? dirtyRev) then self.dirtyShortRev else "dirty-inputs";
      };
    in {
      # nix build ~/.config/nixpkgs#nixosConfigurations.phi-nixos.config.system.build.toplevel
      # OR
      # nixos-rebuild build --flake ~/.config/nixpkgs#phi-nixos
      nixosConfigurations = if nixos then { ${hostname} = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ({ ... }: {
            environment.systemPackages = [ home-manager.packages.${system}.home-manager ];

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

            # `home-manager` uses `/etc/profiles/per-user/` instead of `~/.nix-profile`
            # Required for `fonts.fontconfig.enable = true;`
            home-manager.useUserPackages = true;

            home-manager.users.${user}.imports = home;
            home-manager.extraSpecialArgs = { inherit configRevision; };
          }
        ];
        # Required for `flake-utils-plus` to generate stuff
        specialArgs = { inherit inputs configRevision; };
      }; } else { };

      # nix build ~/.config/nixpkgs#homeConfigurations.enzime@phi-nixos.activationPackage
      # OR
      # home-manager build --flake ~/.config/nixpkgs#enzime@phi-nixos
      homeConfigurations."${user}@${hostname}" = home-manager.lib.homeManagerConfiguration {
        inherit system pkgs;
        configuration = { };
        homeDirectory = "/home/${user}";
        username = user;
        extraModules = home;
        extraSpecialArgs = { inherit configRevision; };
      };
    };
  in mkConfigurations [
    {
      host = "delta";
      user = "enzime";
      system = "x86_64-linux";
      nixos = true;
      modules = builtins.attrValues {
        inherit (modules) fonts gnome i3;
      };
    }
    {
      host = "phi";
      user = "enzime";
      system = "x86_64-linux";
      nixos = true;
      modules = builtins.attrValues {
        inherit (modules) duckdns fonts gaming gnome i3 samba thunar;
      };
    }
    {
      host = "tau";
      hostSuffix = "endeavour";
      user = "enzime";
      system = "x86_64-linux";
      modules = builtins.attrValues {
        inherit (modules) i3 work;
      };
    }
    {
      host = "zeta";
      user = "enzime";
      system = "x86_64-linux";
      nixos = true;
      modules = builtins.attrValues {
        inherit (modules) gnome work;
      };
    }
  ];
}
