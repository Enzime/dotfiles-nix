{
  imports = [ "graphical-minimal" "mpv" ];

  darwinModule = { pkgs, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) rectangle spotify; };

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
      inherit (pkgs) qalculate-gtk remmina;

      # Install Spotify as well for icons
      inherit (pkgs) spotify spotify-tray;
    };

    services.xserver.displayManager.gdm.enable = true;

    programs._1password-gui.enable = true;
    programs._1password-gui.polkitPolicyOwners = [ user ];

    programs._1password.enable = true;
  };

  hmModule = { pkgs, ... }: {
    programs.vscode.package = pkgs.vscode;

    home.file.".ssh/config".text = let
      _1password-agent = if pkgs.stdenv.hostPlatform.isDarwin then
        "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      else
        "~/.1password/agent.sock";
    in ''
      Match host * exec "test -z $SSH_TTY"
        IdentityAgent "${_1password-agent}"
        ForwardAgent yes

      Host *
        ServerAliveInterval 120
    '';
  };
}
