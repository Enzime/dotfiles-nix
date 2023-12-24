{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  disko.devices = {
    disk.primary = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";

        # for running GRUB on MBR
        partitions.grub = {
          size = "1M";
          type = "EF02";
        };

        partitions.bpool = {
          size = "500M";
          content = {
            type = "zfs";
            pool = "bpool";
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

    zpool.bpool = {
      type = "zpool";
      options = { compatibility = "grub2"; };
      rootFsOptions = {
        canmount = "off";
        mountpoint = "none";
      };

      datasets.boot = {
        type = "zfs_fs";

        mountpoint = "/boot";
        options.mountpoint = "legacy";
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

        options."com.sun:auto-snapshot" = "true";
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

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
