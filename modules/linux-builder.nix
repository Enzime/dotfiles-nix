{
  darwinModule =
    { inputs, user, host, keys, options, config, pkgs, lib, ... }: {
      nix.linux-builder.enable = true;
      nix.linux-builder.config = { config, pkgs, lib, ... }: {
        imports = [ (import ./cache.nix).nixosModule ];

        _module.args = { inherit keys; };

        networking.hostName = "${host}-linux-builder";

        services.tailscale.enable = true;

        users.users.root.openssh.authorizedKeys.keys =
          builtins.attrValues { inherit (keys.users) enzime; };

        nix.settings.experimental-features = "nix-command flakes";
        nix.settings.secret-key-files = [ "/etc/nix/key" ];

        nix.settings.trusted-users = lib.mkForce [ "root" ];

        nixpkgs.overlays = [ inputs.nix-overlay.overlay ];
      };
      # Remove when this change is present in upstream nix-darwin
      nix.linux-builder.maxJobs =
        assert !options.nix.linux-builder.maxJobs ? defaultText;
        config.nix.linux-builder.package.nixosConfig.virtualisation.cores;
    };
}
