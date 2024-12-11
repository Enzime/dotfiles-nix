{ config, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  disko.devices = {
    disk.primary = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";

        partitions.esp = {
          size = "1G";
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
            passwordFile = "/tmp/secret.key";
            askPassword = config.disko.testMode;
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

        postCreateHook =
          "zfs list -t snapshot -H -o name | grep -E '^rpool/root@blank$' || zfs snapshot rpool/root@blank";
      };

      datasets.nix = {
        type = "zfs_fs";
        mountpoint = "/nix";
      };

      datasets.persist = {
        type = "zfs_fs";
        mountpoint = "/persist";
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
}
