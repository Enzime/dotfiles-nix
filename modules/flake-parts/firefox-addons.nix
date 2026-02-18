{ inputs, ... }:

{
  flake = {
    overlays.firefox-addons =
      final: prev:
      let
        # We need to import default.nix to use buildFirefoxXpiAddon which doesn't get exported in flake.nix
        # WORKAROUND: In Nix 2.14+, firefox-addons.outPath points to the subdirectory rather than the root
        #             so we need to use sourceInfo.outPath to maintain backwards compatibility
        addons = import "${inputs.firefox-addons.sourceInfo.outPath}/pkgs/firefox-addons" {
          inherit (prev) fetchurl lib stdenv;
        };
      in
      {
        firefox-addons =
          addons
          // (
            let
              inherit (prev.lib) mapAttrs;
              inherit (addons) buildFirefoxXpiAddon;
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
