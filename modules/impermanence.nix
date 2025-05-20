{
  imports = [ "perlless" ];

  nixosModule = { options, config, user, pkgs, lib, ... }: {
    imports = [{
      config = lib.optionalAttrs (options ? clan) {
        clan.core.facts.secretUploadDirectory = "/persist/var/lib/sops-nix";

        sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";
      };
    }];

    preservation.enable = true;

    preservation.preserveAt."/persist" = {
      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/var/lib/alsa"
        "/var/lib/tailscale"
        "/var/lib/sops-nix"
      ];

      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        {
          file = "/etc/zfs/zpool.cache";
          inInitrd = true;
        }
      ];

      users.${user} = config.home-manager.users.${user}.preservation;
    };

    boot.initrd.systemd.enable = true;
    boot.initrd.systemd.services.rollback = {
      description = "Rollback ZFS datasets to a pristine state";
      wantedBy = [ "initrd.target" ];
      requires = [ "zfs-import-rpool.service" ];
      after = [ "zfs-import-rpool.service" ];
      before = [ "sysroot.mount" ];
      path = builtins.attrValues { inherit (pkgs) zfs; };
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        zfs rollback -r rpool/root@blank && echo "rollback complete"
      '';
    };

    # https://github.com/nix-community/preservation/blob/286737ba485f30c1687c833e66f5901a6c8dc019/docs/src/examples.md?plain=1#L32-L36
    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

    # WORKAROUND: necessary while VMs don't have `vars` yet
    virtualisation.allVmVariants = {
      services.openssh.hostKeys = lib.mkForce [{
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }];
    };

    services.tailscale.authKeyFile =
      config.clan.core.vars.generators.tailscale.files.auth-key.path;

    users.mutableUsers = false;

    services.syncthing.dataDir =
      "/persist${config.users.users.${user}.home}/Sync";
  };

  homeModule = {
    preservation = {
      directories = [ "dotfiles" "Sync" ];
      files = [ ".ssh/known_hosts" ".zsh_history" ];
    };

    # By default, zsh will use rename to atomically update `.zsh_history`
    # however this breaks our symlink-based persistence
    programs.zsh.initContent = ''
      setopt NO_HIST_SAVE_BY_COPY
    '';
  };
}
