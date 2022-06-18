{
  imports = [ "firefox" "fonts" "mpv" "ios" ];

  nixosModule = { user, pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) firefox pavucontrol qalculate-gtk remmina;

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
    programs._1password-gui.gid = 5000;
    programs._1password-gui.polkitPolicyOwners = [ user ];

    programs._1password.enable = true;
    programs._1password.gid = 5001;
  };

  hmModule = { pkgs, ... }: {
    programs.vscode.package = pkgs.vscode;
  };
}
