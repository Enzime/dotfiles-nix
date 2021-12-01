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
  hardware.pulseaudio.enable = false;
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.alsa.support32Bit = true;
  services.pipewire.pulse.enable = true;

  # Enable FreeSync
  services.xserver.deviceSection = ''
    Option "VariableRefresh" "true"
  '';

  services.xserver.xrandrHeads = [ {
    output = "DisplayPort-1";
    monitorConfig = ''
      ModeLine "2560x1440@165.08"  645.00  2560 2568 2600 2640  1440 1446 1454 1480 +hsync -vsync
      Option "PreferredMode" "2560x1440@165.08"
      Option "Rotate" "left"
    '';
  }
  {
    output = "DisplayPort-0";
    primary = true;
    monitorConfig = ''
      ModeLine "2560x1440@165.08"  645.00  2560 2568 2600 2640  1440 1446 1454 1480 +hsync -vsync
      Option "PreferredMode" "2560x1440@165.08"
      Option "RightOf" "DisplayPort-0"
      Option "Position" "1440 660"
    '';
  } ];

  # Check that this can be bumped before changing it
  system.stateVersion = "21.05";
}
