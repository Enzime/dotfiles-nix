{ pkgs, lib, ... }:

let
  inherit (lib) mkForce;
in {
  home.sessionVariables = {
    GDK_SCALE                    = 2;
    GDK_DPI_SCALE                = 0.5;
    QT_AUTO_SCREEN_SCALE_FACTOR  = 1;
    QT_FONT_DPI                  = 96;
  };

  xresources.properties = {
    "*dpi" = 192;
    "Xcursor.size" = 48;
  };

  xsession.windowManager.i3.extraConfig = ''
    workspace 101 output eDP1

    exec --no-startup-id i3 workspace 101

    exec --no-startup-id xrandr --output eDP1 --scale '1.6x1.6'
    exec --no-startup-id nm-applet
    exec --no-startup-id xss-lock -- bash -c "i3lock -c 000000; xset dpms force off"
    exec --no-startup-id slack
  '';

  services.polybar = {
    config = {
      "bar/base" = {
        # TODO: add `battery` into `modules-right`
        modules-right = mkForce "dotfiles battery wireless ethernet fs memory date";
      };

      "bar/centre" = {
        monitor = "eDP1";

        # scale everything by 2 for HiDPI
        height = 54;

        font-0 = "Fira Mono:pixelsize=20;1";
        font-1 = "Font Awesome 5 Free:style=Solid:pixelsize=20;1";

        tray-scale = "1.0";
        tray-maxsize = 54;
      };

      "module/battery" = {
        type = "internal/battery";
        battery = "BAT1";
        adapter = "ADP1";
        full-at = 98;

        time-format = "%H:%M";

        label-discharging = "DIS %percentage%% %time% remaining";
        label-charging = "CHG %percentage%% %time% till full";
        label-full = "BAT FULL 100%";
      };
    };
  };
}
