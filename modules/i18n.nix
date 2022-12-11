{
  hmModule = { pkgs, ... }: {
    i18n.inputMethod.enabled = "fcitx5";
    i18n.inputMethod.fcitx5.addons = builtins.attrValues {
      inherit (pkgs) fcitx5-unikey;
    };
  };
}
