{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.cpu.amd.updateMicrocode = true;

  # Run latest kernel for Ryzen and Navi10
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "phi-nixos";

  networking.interfaces.enp34s0.useDHCP = true;

  # Install firmware-linux-nonfree (includes Navi10 drivers)
  hardware.enableRedistributableFirmware = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  services.xserver.displayManager.gdm.autoSuspend = false;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable FreeSync
  services.xserver.deviceSection = ''
    Option "VariableRefresh" "true"
  '';

  services.xserver.xrandrHeads = [ {
    output = "DisplayPort-1";
    primary = true;
    monitorConfig = ''
      ModeLine "1920x1080@239.8"  594.27  1920 1948 1980 2040  1080 1137 1145 1215 +hsync -vsync
      Option "Rotate" "right"
      Option "PreferredMode" "1920x1080@239.8"
    '';
  }
  {
    output = "DisplayPort-2";
    monitorConfig = ''
      Option "RightOf" "DisplayPort-1"
    '';
  } ];

  # Check that this can be bumped before changing it
  system.stateVersion = "21.05";
}
