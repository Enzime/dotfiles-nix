{
  hmModule = { ... }: {
    home.sessionVariablesExtra = ''
      if [[ $XDG_SESSION_TYPE = "x11" ]]; then
        export GDK_SCALE=2
        export GDK_DPI_SCALE=0.5
        export QT_AUTO_SCREEN_SCALE_FACTOR=1
        export QT_FONT_DPI=96
      fi
    '';

    services.polybar.config = {
      "bar/centre" = {
        # scale everything by 2 for HiDPI
        height = 54;

        font-0 = "Fira Mono:pixelsize=20;1";
        font-1 = "Font Awesome 5 Free:style=Solid:pixelsize=20;1";

        tray-scale = "1.0";
        tray-maxsize = 54;
      };
    };
  };
}
