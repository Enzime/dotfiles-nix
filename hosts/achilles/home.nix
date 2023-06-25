{ pkgs, ... }:

{
  home.packages = builtins.attrValues { inherit (pkgs) remmina; };

  programs.vscode.package = pkgs.vscode;

  xsession.windowManager.i3.config.workspaceOutputAssign = [{
    workspace = "101";
    output = "Virtual-1";
  }];

  systemd.user.services.spice-vdagent = {
    Unit = {
      Description = "spice-vdagent guest client";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = { ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -x"; };
  };
}
