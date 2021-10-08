{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf;
in {
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "zeta-nixos";

  # Setting `useDHCP` globally is deprecated
  # manually set `useDHCP` for individual interfaces
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;

  i18n.defaultLocale = "en_US.UTF-8";

  # GNOME runs Wayland by default
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Check that this can be bumped before changing it
  system.stateVersion = "21.05";
}
