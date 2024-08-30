{
  darwinModule = { inputs, user, host, keys, pkgs, ... }: {
    nix.linux-builder.enable = true;
    nix.linux-builder.package = pkgs.darwin.linux-builder;
    nix.linux-builder.config = { config, pkgs, lib, ... }: {
      networking.hostName = "${host}-linux-builder";

      services.tailscale.enable = true;

      users.users.builder.openssh.authorizedKeys.keys =
        builtins.attrValues { inherit (keys.hosts) echo; };

      users.users.root.openssh.authorizedKeys.keys =
        builtins.attrValues { inherit (keys.users) enzime; };

      systemd.services.nix-generate-signing-key = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        path = [ pkgs.nix ];
        script = ''
          [[ -f /etc/nix/key ]] && exit
          nix key generate-secret --key-name ${config.networking.hostName}-1 > /etc/nix/key
          chmod 400 /etc/nix/key
          nix key convert-secret-to-public < /etc/nix/key > /etc/nix/key.pub
        '';
      };

      nix.settings.experimental-features = "nix-command flakes";
      nix.settings.secret-key-files = [ "/etc/nix/key" ];

      nix.settings.trusted-users = lib.mkForce [ "root" ];

      nixpkgs.overlays = [ inputs.nix-overlay.overlay ];
    };
  };
}
