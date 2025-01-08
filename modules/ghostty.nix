{
  homeModule = { options, pkgs, lib, ... }: {
    xdg.configFile."ghostty/config".text =
      assert !options.programs ? ghostty; ''
        theme = hybrid-krompus
        bold-is-bright = true

        quit-after-last-window-closed = true
      '';

    xdg.configFile."ghostty/themes/hybrid-krompus".text =
      assert !options.programs ? ghostty; ''
        # black
        palette = 0=#0a0a0a
        palette = 8=#73645d

        # red
        palette = 1=#e61f00
        palette = 9=#ff3f3d

        # green
        palette = 2=#6dd200
        palette = 10=#c1ff05

        # yellow
        palette = 3=#fa6800
        palette = 11=#ffa726

        # blue
        palette = 4=#255ae4
        palette = 12=#00ccff

        # magenta
        palette = 5=#ff0084
        palette = 13=#ff65a0

        # cyan
        palette = 6=#36fcd3
        palette = 14=#96ffe3

        # white
        palette = 7=#b6afab
        palette = 15=#fff5ed

        background = 0d0c0c
        foreground = fff5ed
        cursor-color = 00ccff
      '';
  };
}
