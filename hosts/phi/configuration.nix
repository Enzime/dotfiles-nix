{ user, pkgs, utils, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.netbootxyz.enable = true;

  hardware.cpu.amd.updateMicrocode = true;

  # Living on the edge for Navi10
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.interfaces.enp34s0.useDHCP = true;

  networking.nameservers = [ "1.1.1.1" ];
  networking.dhcpcd.extraConfig = ''
    nohook resolv.conf
  '';

  nix.registry.ln.to = { type = "git"; url = "file:///home/${user}/nix/nixpkgs"; };

  # Install firmware-linux-nonfree (includes Navi10 drivers)
  hardware.enableRedistributableFirmware = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  services.xserver.displayManager.gdm.autoSuspend = false;

  # Enable FreeSync
  services.xserver.deviceSection = ''
    Option "VariableRefresh" "true"
  '';

  # LWJGL 2 doesn't support modelines with text after WxH
  services.xserver.xrandrHeads = [ {
    output = "DisplayPort-2";
    primary = true;
    monitorConfig = ''
      ModeLine "2560x1441"  645.00  2560 2568 2600 2640  1440 1446 1454 1480 +hsync -vsync
      Option "PreferredMode" "2560x1441"
    '';
  }
  {
    output = "DisplayPort-1";
    monitorConfig = ''
      ModeLine "2560x1441"  645.00  2560 2568 2600 2640  1440 1446 1454 1480 +hsync -vsync
      Option "PreferredMode" "2560x1441"
      Option "RightOf" "DisplayPort-2"
    '';
  } ];

  # WORKAROUND: `escapeSystemdPath` removes the root slash, but we need an escaped root slash
  systemd.services."arion@${utils.escapeSystemdPath "//home/${user}/nix/etebase-arion"}" = {
    description = "Run arion config at %I";
    after = [ "network-online.target" "nix-daemon.service" "podman.service" ];
    wants = [ "network-online.target" ];
    requires = [ "nix-daemon.service" "podman.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "%I";
      ExecStart = "${pkgs.arion}/bin/arion up";
      ExecStop = "${pkgs.arion}/bin/arion stop";
      User = "${user}";
    };
    path = [ pkgs.nix pkgs.docker-client ];
  };

  # Check that this can be bumped before changing it
  system.stateVersion = "21.05";
}
