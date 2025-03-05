{
  # OS modules are required for running `ranger` as `root`
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.ghostty.terminfo ];
  };

  homeModule = { options, pkgs, lib, ... }: {
    programs.ghostty.package =
      if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.ghostty;
    programs.ghostty.settings = {
      theme = "hybrid-krompus";
      bold-is-bright = true;

      quit-after-last-window-closed = true;
    };

    programs.ghostty.themes.hybrid-krompus = {
      palette = [
        # black
        "0=#0a0a0a"
        "8=#73645d"

        # red
        "1=#e61f00"
        "9=#ff3f3d"

        # green
        "2=#6dd200"
        "10=#c1ff05"

        # yellow
        "3=#fa6800"
        "11=#ffa726"

        # blue
        "4=#255ae4"
        "12=#00ccff"

        # magenta
        "5=#ff0084"
        "13=#ff65a0"

        # cyan
        "6=#36fcd3"
        "14=#96ffe3"

        # white
        "7=#b6afab"
        "15=#fff5ed"
      ];
      background = "0d0c0c";
      foreground = "fff5ed";
      cursor-color = "00ccff";
    };
  };
}
