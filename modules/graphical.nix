{
  imports = [ "fonts" "mpv" "vscode" "ios" ];

  nixosModule = { pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) firefox qalculate-gtk pavucontrol tigervnc;

      inherit (pkgs) _1password-gui spotify spotify-tray;
    };

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
  };
}
