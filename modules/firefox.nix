{
  hmModule = { ... }: {
    programs.firefox.enable = true;
    programs.firefox.profiles.default = {
      isDefault = true;
      settings = {
        "browser.tabs.closeWindowWithLastTab" = false;
      };
    };
  };
}
