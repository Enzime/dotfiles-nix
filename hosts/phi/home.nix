{ lib, pkgs, ... }:

let
  inherit (lib) mkForce;
in {
  xsession.windowManager.i3.config.startup = [
    { command = "i3 workspace 101"; notification = false; }
    { command = "i3 workspace 201"; notification = false; }
  ];

  xsession.windowManager.i3.config.workspaceOutputAssign = [
    { workspace = "101"; output = "DisplayPort-2"; }
    { workspace = "201"; output = "DisplayPort-1"; }
  ];

  services.polybar = {
    config = {
      "bar/centre" = {
        monitor = "DisplayPort-2";
      };

      "bar/right" = {
        "inherit" = "bar/base";
        monitor = "DisplayPort-1";
      };
    };
    script = mkForce ''
      polybar centre &
      polybar right &
    '';
  };

  dconf.settings = {
    # `phi` never sleeps
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
  };
}
