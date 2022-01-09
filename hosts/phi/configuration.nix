{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.netbootxyz.enable = true;

  hardware.cpu.amd.updateMicrocode = true;

  # Run latest kernel for Ryzen and Navi10
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.interfaces.enp34s0.useDHCP = true;

  nix.registry.ln.to = { type = "git"; url = "file:///home/enzime/nix/nixpkgs"; };

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
    primary = true;
    monitorConfig = ''
      ModeLine "2560x1440@165.08"  645.00  2560 2568 2600 2640  1440 1446 1454 1480 +hsync -vsync
      Option "PreferredMode" "2560x1440@165.08"
    '';
  }
  {
    output = "DisplayPort-0";
    monitorConfig = ''
      ModeLine "2560x1440@165.08"  645.00  2560 2568 2600 2640  1440 1446 1454 1480 +hsync -vsync
      Option "PreferredMode" "2560x1440@165.08"
      Option "RightOf" "DisplayPort-0"
    '';
  } ];

  # Check that this can be bumped before changing it
  system.stateVersion = "21.05";
}
