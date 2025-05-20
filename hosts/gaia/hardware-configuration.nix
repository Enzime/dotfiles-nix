{
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

        partitions.rpool = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "rpool";
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

      datasets.logs = {
        type = "zfs_fs";

        mountpoint = "/var/log";
        options.mountpoint = "legacy";

        options.acltype = "posixacl";
        options.xattr = "sa";
      };
    };
  };
}
