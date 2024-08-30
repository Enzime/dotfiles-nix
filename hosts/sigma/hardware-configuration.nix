{ ... }:

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
            passwordFile = "/tmp/disk.key";
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
        options.mountpoint = "legacy";

        postCreateHook = "zfs snapshot rpool/root@blank";
      };

      datasets.nix = {
        type = "zfs_fs";

        mountpoint = "/nix";
        options.mountpoint = "legacy";
      };

      datasets.persist = {
        type = "zfs_fs";

        mountpoint = "/persist";
        options.mountpoint = "legacy";
      };

      datasets.logs = {
        type = "zfs_fs";

        mountpoint = "/var/log";
        options.mountpoint = "legacy";

        options.acltype = "posixacl";
        options.xattr = "sa";
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
