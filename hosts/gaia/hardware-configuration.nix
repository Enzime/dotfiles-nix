{
  options,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    {
      config = lib.optionalAttrs (options ? clan) {
        clan.core.vars.generators.luks = {
          files.password.neededFor = "partitioning";
          runtimeInputs = [
            pkgs.coreutils
            pkgs.xkcdpass
          ];
          script = ''
            xkcdpass --numwords 6 --random-delimiters --valid-delimiters='1234567890!@#$%^&*()-_+=,.<>/?' --case random | tr -d "\n" > $out/password
          '';
        };
      };
    }
  ];

  disko.devices = {
    disk.primary = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "gpt";

        partitions.esp = {
          size = "500M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        partitions.luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted";
            passwordFile = config.clan.core.vars.generators.luks.files.password.path;
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
    };

    zpool.rpool = {
      type = "zpool";
      rootFsOptions = {
        canmount = "off";
        mountpoint = "none";

        compression = "zstd";
        "com.sun:auto-snapshot" = "false";
        relatime = "on";
      };

      datasets.root = {
        type = "zfs_fs";
        mountpoint = "/";

        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^rpool/root@blank$' || zfs snapshot rpool/root@blank";
        postMountHook = "mkdir -p ${config.disko.rootMountPoint}/var/lib/sops-nix";
      };

      datasets.nix = {
        type = "zfs_fs";
        mountpoint = "/nix";
      };

      datasets.persist = {
        type = "zfs_fs";
        mountpoint = "/persist";

        postMountHook = ''
          mkdir -p ${config.disko.rootMountPoint}/persist/var/lib/sops-nix
          mount --bind ${config.disko.rootMountPoint}/persist/var/lib/sops-nix ${config.disko.rootMountPoint}/var/lib/sops-nix
        '';
      };

      datasets.logs = {
        type = "zfs_fs";
        mountpoint = "/var/log";

        options.acltype = "posixacl";
        options.xattr = "sa";
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;

  systemd.services.zfs-mount = {
    serviceConfig = {
      ExecStart = [ "${config.boot.zfs.package}/sbin/zfs mount -a -o remount" ];
    };
  };

  # WORKAROUND: LUKS unlock prompt times out
  # https://github.com/NixOS/nixpkgs/issues/250003
  boot.initrd.systemd.services.zfs-import-rpool = {
    after = [ "cryptsetup.target" ];
    wants = [ "cryptsetup.target" ];
  };

  virtualisation.vmVariantWithDisko = {
    disko.devices.disk.primary.content.partitions.luks.content.passwordFile = lib.mkForce (
      toString (pkgs.writeText "password" "apple")
    );
  };
}
