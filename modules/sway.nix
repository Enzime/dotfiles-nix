{
  imports = [ "i3-sway" "wayvnc" ];

  nixosModule = { lib, ... }: {
    # Still overridable with mkForce
    services.displayManager.defaultSession = lib.mkOverride 75 "sway";

    programs.sway.enable = true;
    programs.sway.extraSessionCommands = ''
      source /etc/profile
      if [[ -e /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh ]]; then
        source /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh
      fi
    '';

    xdg.portal.wlr.enable = true;
  };

  hmModule = { config, pkgs, lib, ... }: {
    home.packages = builtins.attrValues { inherit (pkgs) wl-clipboard; };

    home.sessionVariables = { NIXOS_OZONE_WL = 1; };

    wayland.windowManager.sway.enable = true;
    wayland.windowManager.sway.package = null;
    services.swayidle.enable = true;
    programs.waybar.enable = true;

    wayland.windowManager.sway.config = {
      startup = [
        {
          command = "systemctl --user restart waybar";
          always = true;
        }
        { command = "1password"; }
      ];

      floating.criteria = [{ "app_id" = "^floating$"; }];

      input."type:keyboard".xkb_numlock = "enabled";

      keybindings = let
        mod = config.wayland.windowManager.sway.config.modifier;
        screenshotFilename =
          "${config.xdg.userDirs.pictures}/Screenshots/$(date +%y-%m-%d_%H-%M-%S).png";
        grim = "${pkgs.grim}/bin/grim";
        swaymsg = "${pkgs.sway}/bin/swaymsg";
        jq = "${pkgs.jq}/bin/jq";
        slurp = "${pkgs.slurp}/bin/slurp";
      in {
        "Control+Shift+2" = "exec ${
            pkgs.writeShellScript "grim-current-window" ''
              REGION=$(${swaymsg} -t get_tree | ${jq} -j '.. | select(.type?) | select(.focused).rect | "\(.x),\(.y) \(.width)x\(.height)"')
              ${grim} -g "$REGION" ${screenshotFilename}
            ''
          }";
        "Control+Shift+3" = "exec bash -c '${grim} ${screenshotFilename}'";
        "Control+Shift+4" = "exec ${
            pkgs.writeShellScript "grim-slurp" ''
              REGION=$(${swaymsg} -t get_tree | ${jq} -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | ${slurp})
              ${grim} -g "$REGION" ${screenshotFilename}
            ''
          }";

        "${mod}+Shift+Return" =
          "exec ${pkgs.alacritty}/bin/alacritty -o 'window.class.general=\"floating\"'";

        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        "Mod4+l" = "exec loginctl lock-session";

        "${mod}+Shift+r" = "reload";

        "Ctrl+Shift+l" = "exec 1password --lock";
        "Ctrl+Shift+space" = "exec 1password --quick-access";
      };
    };

    services.swayidle.events = let
      swaymsg = "${pkgs.sway}/bin/swaymsg";
      swaylock = lib.getExe pkgs.swaylock;
      # WORKAROUND: 1Password doesn't lock automatically when the screen lock is invoked under Wayland
      lock1Password = pkgs.writeShellScript "lock-1p" ''
        if ${pkgs.procps}/bin/pidof 1password; then
          1password --lock &
        fi
      '';
    in [
      {
        event = "before-sleep";
        command = "loginctl lock-session";
      }
      {
        event = "lock";
        command =
          "${lock1Password} && ${swaylock} -f -c 000000 && ${swaymsg} output '*' dpms off";
      }
    ];
    services.swayidle.timeouts = let swaymsg = "${pkgs.sway}/bin/swaymsg";
    in [
      {
        timeout = 1;
        command = "exit 0";
        resumeCommand = "${swaymsg} output '*' dpms on";
      }
      {
        timeout = 180;
        command = "loginctl lock-session";
        resumeCommand = "${swaymsg} output '*' dpms on";
      }
    ];
    services.swayidle.systemdTarget = "sway-session.target";

    programs.waybar.settings = [{
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "idle_inhibitor" "battery" "clock" "tray" ];
      "sway/window" = { max-length = 50; };
      battery = {
        format = "{capacity}% {icon}";
        format-icons = [ "" "" "" "" "" ];
      };
      clock = {
        format = "{:%a %b %d %I:%M:%S %p}";
        interval = 1;
      };
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
      };
    }];

    programs.waybar.systemd.enable = true;
    programs.waybar.systemd.target = "sway-session.target";

    systemd.user.services.polybar = lib.mkIf config.services.polybar.enable {
      Unit = { Conflicts = [ "sway-session.target" ]; };
    };

    services.mako.enable = true;
    services.mako.defaultTimeout = 5000;
    services.mako.backgroundColor = "#0d0c0c";
    services.mako.borderColor = "#e61f00";
    services.mako.padding = "10,5,10,10";
  };
}
