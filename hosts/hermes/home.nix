{ config, pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  wayland.windowManager.sway.config.workspaceOutputAssign = [{
    workspace = "1";
    output = "Unknown-1";
  }];

  wayland.windowManager.sway.config.output = { Unknown-1 = { scale = "2"; }; };

  xdg.configFile."home-manager".source = lib.mkForce
    (config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Code/private-dotfiles");
}
