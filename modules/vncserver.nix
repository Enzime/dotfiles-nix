{
  imports = [ "graphical" ];

  nixosModule = { user, pkgs, lib, ... }: {
    systemd.services.vnc = {
      description = "Start a VNC and X server";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      before = [ "manual-xinit.service" ];
      wants = [ "manual-xinit.service" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${pkgs.tigervnc}/bin/Xvnc -localhost -geometry 1024x768 -depth 24 -SecurityTypes=None";
        User = user;
      };
    };

    systemd.services.manual-xinit = {
      description = "Start X utilities";
      after = [ "vnc.service" ];
      requires = [ "vnc.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.i3}/bin/i3";
        User = user;
      };
      environment = {
        DISPLAY = ":0";
      };
    };

  };
}
