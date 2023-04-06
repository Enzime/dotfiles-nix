{
  hmModule = { pkgs, ... }: let
    sharedConfig = {
      bars = [ ];

      window = {
        titlebar = false;
        border = 1;
      };

      colors = {
        focused         = { border = "#4c7899"; background = "#e61f00"; text = "#ffffff"; indicator = "#00ccff"; childBorder = "#e61f00"; };
        focusedInactive = { border = "#333333"; background = "#0a0a0a"; text = "#ffffff"; indicator = "#484e50"; childBorder = "#0a0a0a"; };
        unfocused       = { border = "#333333"; background = "#0d0c0c"; text = "#888888"; indicator = "#292d2e"; childBorder = "#0d0c0c"; };
      };

      keybindings = let
        mod = "Mod1";
      in {
        "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";
        "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
        "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";

        "${mod}+Return" = "exec kitty";
        "${mod}+Shift+Return" = "exec kitty --class floating";

        "Mod4+e" = "exec ${pkgs.shutdown-menu}";

        "${mod}+Shift+q" = "kill";
        "${mod}+d" = "exec ${pkgs.bemenu}/bin/bemenu-run -l 30";

        "Control+${mod}+Left" = "focus output left";
        "Control+${mod}+Right" = "focus output right";

        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";

        "Control+${mod}+h" = "focus output left";
        "Control+${mod}+l" = "focus output right";

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        "Control+${mod}+Shift+Left" = "move container to output left; focus output left";
        "Control+${mod}+Shift+Right" = "move container to output right; focus output right";

        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";

        "Control+${mod}+Shift+h" = "move container to output left; focus output left";
        "Control+${mod}+Shift+l" = "move container to output right; focus output right";

        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        "${mod}+Shift+v" = "split h";
        "${mod}+v" = "split v";
        "${mod}+f" = "fullscreen toggle";

        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";

        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";

        "${mod}+a" = "focus parent";

        "${mod}+o" = "mode osu";
        "${mod}+r" = "mode resize";
      };

      modes = {
        osu = { End = "mode default"; };
        resize = {
          h = "resize shrink width 2 px or 2 ppt";
          j = "resize grow height 2 px or 2 ppt";
          k = "resize shrink height 2 px or 2 ppt";
          l = "resize grow width 2 px or 2 ppt";

          Left = "resize shrink width 2 px or 2 ppt";
          Down = "resize grow height 2 px or 2 ppt";
          Up = "resize shrink height 2 px or 2 ppt";
          Right = "resize grow width 2 px or 2 ppt";

          "Shift+h" = "resize shrink width 20 px or 20 ppt";
          "Shift+j" = "resize grow height 20 px or 20 ppt";
          "Shift+k" = "resize shrink height 20 px or 20 ppt";
          "Shift+l" = "resize grow width 20 px or 20 ppt";

          "Shift+Left" = "resize shrink width 20 px or 20 ppt";
          "Shift+Down" = "resize grow height 20 px or 20 ppt";
          "Shift+Up" = "resize shrink height 20 px or 20 ppt";
          "Shift+Right" = "resize grow width 20 px or 20 ppt";

          Escape = "mode default";
        };
      };
    };
  in {
    xsession.windowManager.i3.config = sharedConfig;
    wayland.windowManager.sway.config = sharedConfig;

    programs.alacritty.enable = true;
    programs.kitty.enable = true;
    programs.feh.enable = true;
    services.udiskie.enable = true;

    programs.feh = {
      buttons = {
        zoom_in = 4;
        zoom_out = 5;
      };

      keybindings = {
        save_image = null;
        delete = null;
      };
    };

    systemd.user.services.pantheon-polkit-agent = {
      Unit = {
        Description = "Pantheon Polkit Agent";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = {
        ExecStart =
          "${pkgs.pantheon.pantheon-agent-polkit}/libexec/policykit-1-pantheon/io.elementary.desktop.agent-polkit";
      };
    };
  };
}
