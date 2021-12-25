{
  imports = [ "fonts" "mpv" "vscode" "ios" ];

  nixosModule = { pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) firefox spotify qalculate-gtk pavucontrol;

      inherit (pkgs) _1password-gui;
    };

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
  };
}
