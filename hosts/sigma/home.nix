{ ... }:

{
  home.file.".ssh/config".text = ''
    Host *
      IdentityAgent ~/.1password/agent.sock
  '';

  xsession.windowManager.i3.config.workspaceOutputAssign = [
    { workspace = "101"; output = "eDP-1"; }
  ];

  wayland.windowManager.sway.config.output = {
    eDP-1 = {
      scale = "1.5";
    };
  };

  wayland.windowManager.sway.config.workspaceOutputAssign = [
    { workspace = "1"; output = "eDP-1"; }
  ];

  services.polybar.config = {
    "module/battery" = {
      battery = "BAT1";
      adapter = "ACAD";
    };
  };

  xdg.userDirs.download = "\$HOME/Downloads";
  xdg.userDirs.pictures = "\$HOME/Pictures";
}
