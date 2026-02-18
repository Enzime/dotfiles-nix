{
  imports = [
    "greetd"
    "sway"
  ];

  nixosModule =
    { user, ... }:
    {
      users.users.${user}.linger = true;
    };

  homeModule =
    { pkgs, lib, ... }@args:
    let
      vncEnvironment = [
        "WLR_BACKENDS=headless"
        "WLR_LIBINPUT_NO_DEVICES=1"
        "WAYLAND_DISPLAY=wayland-1"
      ];
    in
    {
      # Move regular wayvnc to another port
      xdg.configFile."wayvnc/config".text = ''
        port=5901
      '';

      services.swayidle.enable = lib.mkForce false;

      wayland.windowManager.sway.config.workspaceOutputAssign = [
        {
          workspace = "1";
          output = "HEADLESS-1";
        }
      ];

      systemd.user.services.import-path = {
        Unit = {
          Description = "Import PATH from zsh";
        };
        Service = {
          Environment = [
            # Necessary for running interactive Zsh (`zsh -i` which sources `~/.zshrc`) which
            # is necessary for setting some components of the PATH
            "PATH=/run/current-system/sw/bin"
            # NixOS doesn't expose the PATH in the NixOS module system so we need to unset this
            # environment variable to get NixOS to set the default PATH for us
            "__NIXOS_SET_ENVIRONMENT_DONE="
          ];
          Type = "oneshot";
          ExecStart = "${lib.getExe pkgs.zsh} -ic 'systemctl --user import-environment PATH'";
          RemainAfterExit = true;
        };
      };

      systemd.user.services.wayvnc-headless = lib.mkIf (args ? osConfig) {
        Unit = {
          Description = "VNC server for headless session";
          Requires = [
            "import-path.service"
            "sway-headless.service"
          ];
          After = [
            "import-path.service"
            "sway-headless.service"
          ];
        };
        Service = {
          Type = "exec";
          ExecStart = "${lib.getExe pkgs.wayvnc} --config=${
            pkgs.writeTextFile {
              name = "wayvnc-headless.conf";
              text = ''
                address=0.0.0.0
                port=5900
              '';
            }
          }";
          Environment = vncEnvironment;
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };

      systemd.user.services.sway-headless = {
        Unit = {
          Description = "Wayland compositor for headless session";
          Requires = [ "import-path.service" ];
          After = [ "import-path.service" ];
        };
        Service = {
          Environment = vncEnvironment;
          ExecStart = lib.getExe pkgs.sway;
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
