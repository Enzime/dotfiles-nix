{
  hmModule = { pkgs, ... }: {
    i18n.inputMethod.enabled = "fcitx5";
    i18n.inputMethod.fcitx5.addons = builtins.attrValues {
      inherit (pkgs) fcitx5-unikey;
    };

    xdg.configFile."fcitx5/profile".force = true;
    xdg.configFile."fcitx5/profile".text = ''
      [Groups/0]
      Name=Default
      Default Layout=us
      DefaultIM=unikey

      [Groups/0/Items/0]
      Name=keyboard-us
      Layout=

      [Groups/0/Items/1]
      Name=unikey
      Layout=

      [GroupOrder]
      0=Default
    '';
  };
}
