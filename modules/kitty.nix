{
  # OS modules are required for running `ranger` as `root`
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.kitty.terminfo ];
  };

  darwinModule = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.kitty.terminfo ];
  };

  hmModule = { pkgs, ... }: {
    home.packages = [ pkgs.kitty.terminfo ];

    programs.kitty.font.name = "DejaVu Sans Mono";
    programs.kitty.font.size = 10;
    programs.kitty.keybindings = {
      "shift+page_up"   = "scroll_page_up";
      "shift+page_down" = "scroll_page_down";
    };
    programs.kitty.settings = {
      bold_font = "DejaVu Sans Mono Bold";
      bold_is_bright = true;
      text_composition_strategy = "legacy";

      foreground = "#fff5ed";
      background = "#0d0c0c";
      cursor     = "#00ccff";

      # black
      color0  = "#0a0a0a";
      color8  = "#73645d";

      # red
      color1  = "#e61f00";
      color9  = "#ff3f3d";

      # green
      color2  = "#6dd200";
      color10 = "#c1ff05";

      # yellow
      color3  = "#fa6800";
      color11 = "#ffa726";

      # blue
      color4  = "#255ae4";
      color12 = "#00ccff";

      # magenta
      color5  = "#ff0084";
      color13 = "#ff65a0";

      # cyan
      color6  = "#36fcd3";
      color14 = "#96ffe3";

      # white
      color7  = "#b6afab";
      color15 = "#fff5ed";
    };
  };
}

