{ config, lib, utils, ... }:

{
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  disko.devices = {
    disk.primary = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };

          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
    };

    lvm_vg.pool = {
      type = "lvm_vg";
      lvs = {
        # Needs to be created before root and currently disko implicitly uses alphabetical ordering
        aswap = {
          size = "16G";
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

  fileSystems."/mnt/phi" = {
    device = "enzime@phi:/";
    fsType = "fuse.sshfs";
    noCheck = true;
    options = [
      "noauto"
      "x-systemd.automount"
      "_netdev"
      "IdentityFile=/etc/ssh/ssh_host_ed25519_key"
      "allow_other"
      "uid=1000"
      "gid=100"
      "ConnectTimeout=1"
      "x-systemd.mount-timeout=10s"
      "ServerAliveInterval=1"
      "ServerAliveCountMax=5"
    ];
  };

  systemd.units."${utils.escapeSystemdPath "/mnt/phi"}.mount" = {
    text = ''
      [Unit]
      StartLimitIntervalSec=0
    '';
    overrideStrategy = "asDropin";
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
