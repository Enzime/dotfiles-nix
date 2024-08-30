{
  nixosModule = { config, user, host, pkgs, lib, ... }: {
    environment.persistence."/persist" = {
      enable = lib.mkForce true;
      hideMounts = true;
      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/var/lib/alsa"
        "/var/lib/tailscale"
      ];
      files = [ "/etc/machine-id" "/etc/zfs/zpool.cache" ];
      # We need this to create `/persist/home/<user>` for the home-manager module
      users.${user}.files = [ ".persist" ];
    };

    programs.fuse.userAllowOther = true;

    boot.initrd.systemd.enable = true;
    boot.initrd.systemd.services.rollback = {
      description = "Rollback ZFS datasets to a pristine state";
      wantedBy = [ "initrd.target" ];
      after = [ "zfs-import-rpool.service" ];
      before = [ "sysroot.mount" ];
      path = builtins.attrValues { inherit (pkgs) zfs; };
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        zfs rollback -r rpool/root@blank && echo "rollback complete"
      '';
    };

    services.openssh.hostKeys = lib.mkForce [{
      path = "/persist/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }];

    services.tailscale.authKeyFile = "/persist/tailscale.key";

    # Change when https://github.com/NixOS/nixpkgs/pull/338210 is merged
    systemd.services.tailscaled-autoconnect.serviceConfig.ExecStart =
      assert ((builtins.match ".*BackendState.*"
        config.systemd.services.tailscaled-autoconnect.script) == null);
      lib.mkForce (lib.getExe (pkgs.writeShellApplication {
        name = "tailscaled-autoconnect-with-impermanence";
        runtimeInputs = [ config.services.tailscale.package pkgs.jq ];
        text = let
          cfg = config.services.tailscale;
          statusCommand = "tailscale status --json | jq -r '.BackendState'";
        in ''
          while [[ "$(${statusCommand})" == "NoState" ]]; do
            sleep 0.5
          done
          status=$(${statusCommand})
          if [[ "$status" == "NeedsLogin" || "$status" == "NeedsMachineAuth" ]]; then
            tailscale up --auth-key 'file:${cfg.authKeyFile}' ${
              lib.escapeShellArgs cfg.extraUpFlags
            }
            rm -v ${cfg.authKeyFile}
          fi
        '';
      }));

    users.mutableUsers = false;

    age.secrets.password_hash.file =
      ../secrets/password-hash_${user}-${host}.age;

    users.users.${user} = {
      hashedPasswordFile = config.age.secrets.password_hash.path;
      password = lib.mkForce null;
    };

    system.activationScripts.expire-password = lib.mkForce "";
  };

  homeModule = { config, ... }: {
    home.persistence."/persist${config.home.homeDirectory}" = {
      directories = [ "dotfiles" ];
      files = [ ".ssh/known_hosts" ".zsh_history" ];
      allowOther = true;
    };

    # By default, zsh will use rename to atomically update `.zsh_history`
    # however this breaks our symlink-based persistence
    programs.zsh.initExtra = ''
      setopt NO_HIST_SAVE_BY_COPY
    '';
  };
}
