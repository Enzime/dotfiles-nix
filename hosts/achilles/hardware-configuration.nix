{ ... }:

{
  boot.initrd.availableKernelModules =
    [ "virtio_gpu" "virtio_pci" "xhci_pci" "usbhid" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  disko.devices = {
    disk.vda = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "ESP";
            start = "1MiB";
            end = "512MiB";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "luks";
            start = "512MiB";
            end = "100%";
            content = {
              type = "luks";
              name = "crypted";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          }
        ];
      };
    };
    lvm_vg.pool = {
      type = "lvm_vg";
      lvs = {
        # Needs to be created before root and currently disko implicitly uses alphabetical ordering
        aswap = {
          size = "4G";
          content = { type = "swap"; };
        };

        root = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
