{
  nixosModule = { user, host, lib, ... }: {
    age.secrets.x11vnc = let file = ../secrets/x11vnc_${host}.age;
    in lib.mkIf (builtins.pathExists file) {
      inherit file;
      path = "/home/${user}/.vnc/passwd";
      owner = user;
    };
  };

  hmModule = { config, pkgs, ... }: {
    systemd.user.services.x11vnc = {
      Unit = { Description = "VNC Server for X11"; };

      Service = {
        # Only allow Tailscale traffic
        ExecStart =
          "${pkgs.x11vnc}/bin/x11vnc -rfbport 5900 -allow 100. -passwdfile ${config.home.homeDirectory}/.vnc/passwd -shared -forever -nap";
        ExecStop = "${pkgs.x11vnc}/bin/x11vnc -R stop";
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
}
