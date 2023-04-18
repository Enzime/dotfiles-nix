{ config, inputs, lib, pkgs, modulesPath, utils, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
      (inputs.disko.nixosModules.disko)
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  disko.devices = {
    disk.nvme0n1 = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            type = "partition";
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
            type = "partition";
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
          type = "lvm_lv";
          size = "16G";
          content = {
            type = "swap";
          };
        };

        root = {
          type = "lvm_lv";
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

  fileSystems."/mnt/phi" =
    { device = "enzime@phi:/";
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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
