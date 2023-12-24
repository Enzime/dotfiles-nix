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

  hmModule = { pkgs, lib, ... }@args: {
    services.redshift.enable = lib.mkForce false;
    services.screen-locker.enable = lib.mkForce false;

    systemd.user.services.vnc = lib.mkIf (args ? osConfig) {
      Unit = { Description = "Start a VNC and X server"; };
      Service = {
        Environment = "PATH=/run/current-system/sw/bin";
        Type = "exec";
        ExecStart = "${pkgs.writeShellScript "vnc-start" ''
          WRAPPER=${args.osConfig.services.xserver.displayManager.sessionData.wrapper}
          WRAPPER_ARGS=$(${
            lib.getExe pkgs.ripgrep
          } '(?<=^Exec=).*' --pcre2 --only-matching --no-line-number --color=never ${
            builtins.elemAt
            args.osConfig.services.xserver.displayManager.sessionPackages 0
          }/share/xsessions/none+i3.desktop)
          startx $WRAPPER $WRAPPER_ARGS -- ${pkgs.tigervnc}/bin/Xvnc -geometry 1366x768 -depth 24 -SecurityTypes=None
        ''}";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };
  };
}
