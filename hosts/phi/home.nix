{ lib, pkgs, ... }:

let
  inherit (lib) mkForce;
in {
  home.packages = builtins.attrValues {
    inherit (pkgs) signal-desktop;
  };

  # Disable tab bar when using vertical tabs
  home.file.".mozilla/firefox/userChrome.css".text = ''
    #TabsToolbar { visibility: collapse !important; }
  '';

  xsession.windowManager.i3.extraConfig = ''
    workspace 101 output DisplayPort-1
    workspace 201 output DisplayPort-0

    exec --no-startup-id i3 workspace 101
    exec --no-startup-id i3 workspace 201
  '';

  services.polybar = {
    config = {
      "bar/left" = {
        "inherit" = "bar/base";
        monitor = "DisplayPort-1";
      };

      "bar/centre" = {
        monitor = "DisplayPort-0";
      };
    };
    script = mkForce ''
      polybar left &
      polybar centre &
    '';
  };

  dconf.settings = {
    # `phi` never sleeps
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
  };
}
