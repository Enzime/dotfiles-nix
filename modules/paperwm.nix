{
  imports = [ "gnome" ];

  hmModule = { pkgs, lib, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs.gnomeExtensions) paperwm;

      # Whilst PaperWM is buggy on NixOS, install these extra extensions
      # WORKAROUND: https://github.com/paperwm/PaperWM/issues/376#issuecomment-880562319
      inherit (pkgs.gnomeExtensions) cleaner-overview;
      inherit (pkgs.gnomeExtensions) vertical-overview;
      inherit (pkgs.gnomeExtensions) disable-workspace-switch-animation-for-gnome-40;
    };

    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [
          "paperwm@hedning:matrix.org"

          "overview_cleaner@gonza.com"
          "vertical-overview@RensAlthuis.github.com"
          "instantworkspaceswitcher@amalantony.net"
        ];
      };

      "org/gnome/shell/overrides" = {
          workspaces-only-on-primary = false;
          edge-tiling = false;
          attach-modal-dialogs = false;
      };
    };
  };
}
