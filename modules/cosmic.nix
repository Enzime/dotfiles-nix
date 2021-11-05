{
  hmModule = { pkgs, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) pop-control-center;
      inherit (pkgs.gnomeExtensions) pop-cosmic pop-shell cosmic-dock cosmic-workspaces;
    };

    gtk.enable = true;
    gtk.theme.name = "PopOS";
    gtk.theme.package = pkgs.pop-gtk-theme;
    gtk.iconTheme.name = "PopOS";
    gtk.iconTheme.package = pkgs.pop-icon-theme;

    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [
          "pop-shell@system76.com"
          "pop-cosmic@system76.com"
          "cosmic-dock@system76.com"
          "cosmic-workspaces@system76.com"
        ];
      };
    };
  };
}
