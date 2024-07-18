{
  # OS modules are required for running `ranger` as `root`
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.termite.terminfo ];
  };

  darwinModule = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.termite.terminfo ];
  };

  homeModule = { pkgs, config, ... }: {
    home.packages = [ pkgs.termite.terminfo ];

    programs.termite = {
      font = "DejaVu Sans Mono 10";
      scrollbackLines = -1;
      colorsExtra = ''
        # special
        foreground      = #fff5ed
        foreground_bold = #fff5ed
        cursor          = #00ccff
        background      = #0d0c0c

        # black
        color0  = #0a0a0a
        color8  = #73645d

        # red
        color1  = #e61f00
        color9  = #ff3f3d

        # green
        color2  = #6dd200
        color10 = #c1ff05

        # yellow
        color3  = #fa6800
        color11 = #ffa726

        # blue
        color4  = #255ae4
        color12 = #00ccff

        # magenta
        color5  = #ff0084
        color13 = #ff65a0

        # cyan
        color6  = #36fcd3
        color14 = #96ffe3

        # white
        color7  = #b6afab
        color15 = #fff5ed
      '';
    };
  };
}
