{
  imports = [ "firefox" "fonts" "mpv" ];

  darwinModule = { pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) rectangle spotify;
    };

    system.activationScripts.extraActivation.text = ''
      cp ${pkgs._1password}/bin/op /usr/local/bin/op
    '';

    # Close Terminal if shell exited cleanly
    system.activationScripts.extraUserActivation.text = ''
      plutil -replace "Window Settings.Basic.shellExitAction" -integer 1 ~/Library/Preferences/com.apple.Terminal.plist
    '';

    services.karabiner-elements.enable = true;
  };

  nixosModule = { user, pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) firefox pavucontrol qalculate-gtk remmina;

      # Install Spotify as well for icons
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
    programs._1password-gui.polkitPolicyOwners = [ user ];

    programs._1password.enable = true;
  };

  hmModule = { pkgs, ... }: {
    programs.vscode.package = pkgs.vscode;
  };
}
