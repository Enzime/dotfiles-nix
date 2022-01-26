{
  hmModule = { ... }: {
    programs.firefox.enable = true;
    programs.firefox.profiles.default = {
      isDefault = true;
      settings = {
        "browser.tabs.closeWindowWithLastTab" = false;
      };
    };

    programs.zsh.profileExtra = ''
      if [[ $XDG_SESSION_TYPE = "wayland" ]]; then
        export MOZ_ENABLE_WAYLAND=1
      fi
    '';
  };
}
