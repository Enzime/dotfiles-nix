{
  hmModule = { config, pkgs, ... }: {
    systemd.user.services.wayvnc = {
      Unit = {
        Description = "VNC Server for Sway";
        # Allow it to restart infinitely
        StartLimitIntervalSec = 0;
      };

      Service = {
        ExecStart = "${pkgs.writeShellScript "wayvnc-start" ''
          if [[ $XDG_SESSION_TYPE = "wayland" ]]; then
            ${pkgs.wayvnc}/bin/wayvnc && exit 1
          else
            exit 0
          fi
        ''}";
        Restart = "on-failure";
        RestartSec = "1m";
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };

    # As we don't open the firewall, it should only be accessible over Tailscale
    xdg.configFile."wayvnc/config".text = ''
      address=0.0.0.0
    '';
  };
}
