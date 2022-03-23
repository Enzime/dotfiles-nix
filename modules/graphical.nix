{
  imports = [ "firefox" "fonts" "mpv" "ios" ];

  nixosModule = { pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) firefox qalculate-gtk pavucontrol tigervnc;

      inherit (pkgs) spotify spotify-tray;
    };

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    sound.enable = true;
    hardware.pulseaudio.enable = false;
    services.pipewire.enable = true;
    services.pipewire.alsa.enable = true;
    services.pipewire.alsa.support32Bit = true;
    services.pipewire.pulse.enable = true;

    programs._1password-gui.enable = true;
    programs._1password-gui.groupId = 5000;
  };

  hmModule = { pkgs, ... }: {
    programs.vscode.package = pkgs.vscode;
  };
}
