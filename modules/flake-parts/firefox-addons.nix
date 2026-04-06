{ inputs, ... }:

{
  flake = {
    overlays.firefox-addons =
      final: prev:
      let
        inherit (inputs.firefox-addons.lib.${prev.stdenv.hostPlatform.system}) buildFirefoxXpiAddon;

        # We need to use their overlay directly instead of packages as it won't use
        # our config like allowing unfree packages
        addons = (inputs.firefox-addons.overlays.default final prev).firefox-addons;
      in
      {
        firefox-addons =
          addons
          // (
            let
              inherit (prev.lib) mapAttrs;
            in
            mapAttrs
              (name: addon: if addons ? ${name} then throw "firefox-addons.${name} already exists" else addon)
              {
                masked-email-manager = buildFirefoxXpiAddon {
                  pname = "masked-email-manager";
                  version = "1.7.2";
                  addonId = "{c48d361c-1173-11ee-be56-0242ac120002}";
                  url = "https://addons.mozilla.org/firefox/downloads/file/4585287/masked_email_manager-1.7.2.xpi";
                  sha256 = "sha256-UBcHS4ackk1RpWTRAyj8SB2VYe4hVIfive23hN/hd1I=";
                  meta = { };
                };

                purple-private-windows = buildFirefoxXpiAddon {
                  pname = "purple-private-windows";
                  version = "1.1";
                  addonId = "purplePrivateWindows@waldemar.b";
                  url = "https://addons.mozilla.org/firefox/downloads/file/3423600/purple_private_windows-1.1.xpi";
                  sha256 = "sha256-FMu5tY7PwPTpUzrnbK2igfJhSCKUb1OMSPIhjIBwLok=";
                  meta = { };
                };
              }
          );
      };
  };
}
