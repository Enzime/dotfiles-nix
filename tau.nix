{ lib, ... }:

let
    inherit (lib) mkDefault;
in {
  xsession.windowManager.i3 = mkDefault {
    extraConfig = ''
      workspace 101 output eDP1
      
      exec --no-startup-id i3 workspace 101

      exec --no-startup-id xrandr --output eDP1 --scale '1.6x1.6'
      exec --no-startup-id nm-applet
      exec --no-startup-id xss-lock -- bash -c "i3lock -c 000000; xset dpms force off"
      exec --no-startup-id slack
    '';
  };
  
  services.polybar = mkDefault {
    config = {
      "bar/base" = {
        modules-right = "battery wireless ethernet fs memory date";
      };

      "bar/centre" = {
        monitor = "eDP1";
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
    script = ''
      polybar centre &
    '';
  };
}
