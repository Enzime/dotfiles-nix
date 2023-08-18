{ inputs, config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (inputs.nixos-apple-silicon.nixosModules.default)
  ];

  boot.initrd.availableKernelModules = [ "usb_storage" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."crypted".device = "/dev/nvme0n1p5";

  fileSystems."/" = {
    device = "/dev/pool/root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/47AA-19F6";
    fsType = "vfat";
  };

  swapDevices = [{ device = "/dev/pool/swap"; }];

  hardware.asahi.extractPeripheralFirmware =
    builtins.pathExists "${inputs.secrets}/asahi-firmware";
  hardware.asahi.peripheralFirmwareDirectory =
    if config.hardware.asahi.extractPeripheralFirmware then
      "${inputs.secrets}/asahi-firmware"
    else
      null;
  hardware.asahi.useExperimentalGPUDriver = true;
  hardware.asahi.experimentalGPUInstallMode = "driver";

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
