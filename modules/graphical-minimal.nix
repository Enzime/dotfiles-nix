{
  imports = [ "firefox" "fonts" "greetd" ];

  darwinModule = { user, pkgs, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) rectangle; };

    launchd.user.agents.rectangle = {
      command =
        ''"/Applications/Nix Apps/Rectangle.app/Contents/MacOS/Rectangle"'';
      serviceConfig.RunAtLoad = true;
    };

    # Close Terminal if shell exited cleanly
    system.activationScripts.extraActivation.text = ''
      if [[ -f ~${user}/Library/Preferences/com.apple.Terminal.plist ]]; then
        sudo -u ${user} plutil -replace "Window Settings.Basic.shellExitAction" -integer 1 ~${user}/Library/Preferences/com.apple.Terminal.plist
      fi
    '';

    # WORKAROUND: Screensaver starts on the login screen and cannot be closed from VNC
    system.defaults.CustomSystemPreferences."/Library/Preferences/com.apple.screensaver".loginWindowIdleTime =
      0;
  };

  nixosModule = { user, pkgs, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) gparted pavucontrol; };

    services.xserver.enable = true;

    services.pulseaudio.enable = false;
    services.pipewire.enable = true;
    services.pipewire.alsa.enable = true;
    services.pipewire.alsa.support32Bit = true;
    services.pipewire.pulse.enable = true;
  };
}

