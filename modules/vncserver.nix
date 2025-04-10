{
  imports = [ "i3" ];

  nixosModule = { user, pkgs, lib, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs.xorg) xinit; };

    # Let VNC use :0
    services.xserver.displayManager.lightdm.extraConfig = ''
      minimum-display-number=1
    '';

    users.users.${user}.linger = true;
  };

  homeModule = { pkgs, lib, ... }@args: {
    services.redshift.enable = lib.mkForce false;
    services.screen-locker.enable = lib.mkForce false;

    systemd.user.services.import-path = {
      Unit = { Description = "Import PATH from zsh"; };
      Service = {
        Environment = [
          # Necessary for running interactive Zsh (`zsh -i` which sources `~/.zshrc`) which
          # is necessary for setting some components of the PATH
          "PATH=/run/current-system/sw/bin"
          # NixOS doesn't expose the PATH in the NixOS module system so we need to unset this
          # environment variable to get NixOS to set the default PATH for us
          "__NIXOS_SET_ENVIRONMENT_DONE="
        ];
        Type = "oneshot";
        ExecStart = "${
            lib.getExe pkgs.zsh
          } -ic 'systemctl --user import-environment PATH'";
        RemainAfterExit = true;
      };
    };

    systemd.user.services.vnc = lib.mkIf (args ? osConfig) {
      Unit = {
        Description = "Start a VNC and X server";
        Requires = [ "import-path.service" ];
        After = [ "import-path.service" ];
      };
      Service = {
        Type = "exec";
        ExecStart = "${pkgs.writeShellScript "vnc-start" ''
          WRAPPER=${args.osConfig.services.displayManager.sessionData.wrapper}
          WRAPPER_ARGS=$(${
            lib.getExe pkgs.ripgrep
          } '(?<=^Exec=).*' --pcre2 --only-matching --no-line-number --color=never ${
            builtins.elemAt
            args.osConfig.services.displayManager.sessionPackages 0
          }/share/xsessions/none+i3.desktop)
          startx $WRAPPER $WRAPPER_ARGS -- ${
            lib.getExe' pkgs.tigervnc "Xvnc"
          } -geometry 1366x768 -depth 24 -SecurityTypes=None
        ''}";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };
  };
}
