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

  xsession.windowManager.i3.config.startup = [
    { command = "signal-desktop"; always = true; }
    { command = "i3 workspace 101"; notification = false; }
    { command = "i3 workspace 201"; notification = false; }
  ];

  xsession.windowManager.i3.config.workspaceOutputAssign = [
    { workspace = "101"; output = "DisplayPort-1"; }
    { workspace = "201"; output = "DisplayPort-0"; }
  ];

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
