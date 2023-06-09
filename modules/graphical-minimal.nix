{
  imports = [ "firefox" "fonts" ];

  darwinModule = { pkgs, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) rectangle; };

    # Close Terminal if shell exited cleanly
    system.activationScripts.extraUserActivation.text = ''
      plutil -replace "Window Settings.Basic.shellExitAction" -integer 1 ~/Library/Preferences/com.apple.Terminal.plist
    '';

    # WORKAROUND: Screensaver starts on the login screen and cannot be closed from VNC
    system.activationScripts.extraActivation.text = ''
      defaults write /Library/Preferences/com.apple.screensaver loginWindowIdleTime 0
    '';
  };

  nixosModule = { user, pkgs, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) pavucontrol; };

    services.xserver.enable = true;

    sound.enable = true;
    hardware.pulseaudio.enable = false;
    services.pipewire.enable = true;
    services.pipewire.alsa.enable = true;
    services.pipewire.alsa.support32Bit = true;
    services.pipewire.pulse.enable = true;
  };
}

