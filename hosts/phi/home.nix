{ pkgs, lib, ... }:

let
  inherit (lib) mkForce;
in {
  home.file.".ssh/config".text = ''
    Host *
      IdentityAgent ~/.1password/agent.sock
      ServerAliveInterval 120
  '';

  xsession.windowManager.i3.config.startup = [
    { command = "i3 workspace 101"; notification = false; }
    { command = "i3 workspace 201"; notification = false; }
  ];

  xsession.windowManager.i3.config.workspaceOutputAssign = [
    { workspace = "101"; output = "DisplayPort-2"; }
  ];

  services.polybar = {
    config = {
      "bar/centre" = {
        monitor = "DisplayPort-2";
      };
    };
    script = mkForce ''
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
