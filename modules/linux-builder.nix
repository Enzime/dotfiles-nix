{
  darwinModule =
    { inputs, user, host, keys, options, config, pkgs, lib, ... }: {
      nix.linux-builder.enable = true;
      nix.linux-builder.config = { config, lib, ... }: {
        imports = [
          (import ./cache.nix).nixosModule
          (import ./flakes.nix).nixosModule
          (import ./ghostty.nix).nixosModule
        ];

        system.build.bootstrap = pkgs.writeShellApplication {
          name = "bootstrap-${host}-linux-builder";
          runtimeInputs = [ ];
          text = ''
            set -euxo pipefail

            op read "op://trimcmujfu5fjcx5u4u752yk2i/${host}-linux-builder Nix signing key/key" | ssh root@linux-builder bash -c "cat > /etc/nix/key; chmod 400 /etc/nix/key"
            ssh root@linux-builder tailscale up
          '';
        };

        _module.args = { inherit keys; };

        networking.hostName = "${host}-linux-builder";

        services.tailscale.enable = true;

        users.users.enzime = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];

          openssh.authorizedKeys.keys =
            builtins.attrValues { inherit (keys.users) enzime; };
        };

        users.users.root.openssh.authorizedKeys.keys =
          builtins.attrValues { inherit (keys.users) enzime; };

        nix.settings.secret-key-files = [ "/etc/nix/key" ];

        nix.settings.trusted-users = lib.mkForce [ "root" ];

        # By default NixOS and nix-darwin oversubscribe a lot (max-jobs = auto, cores = 0)
        # instead we would rather only oversubscribe a little bit
        nix.settings.cores = 2;
      };

      nix.settings.trusted-public-keys =
        [ keys.signing."${host}-linux-builder" ];
    };
}
