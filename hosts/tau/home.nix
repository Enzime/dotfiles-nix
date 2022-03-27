{ pkgs, lib, ... }:

{
  xresources.properties = {
    "*dpi" = 192;
    "Xcursor.size" = 48;
  };

  xsession.windowManager.i3.config.startup = [
    { command = "xrandr --output eDP-1 --scale '1.6x1.6'"; notification = false; }
    { command = "nm-applet"; notification = false; }
    { command = "slack"; notification = false; }
  ];

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
    "bar/centre" = {
      monitor = "eDP-1";
    };

    "module/battery" = {
      battery = "BAT1";
      adapter = "ADP1";
    };
  };
}
