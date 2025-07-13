{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.firefox-addons.url =
    "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
  inputs.firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { firefox-addons, ... }: {
    overlay = final: prev:
      let
        # We need to import default.nix to use buildFirefoxXpiAddon which doesn't get exported in flake.nix
        # WORKAROUND: In Nix 2.14+, firefox-addons.outPath points to the subdirectory rather than the root
        #             so we need to use sourceInfo.outPath to maintain backwards compatibility
        addons =
          import "${firefox-addons.sourceInfo.outPath}/pkgs/firefox-addons" {
            inherit (prev) fetchurl lib stdenv;
          };
      in {
        firefox-addons = addons // (let
          inherit (prev.lib) mapAttrs;
          inherit (addons) buildFirefoxXpiAddon;
        in mapAttrs (name: addon:
          if addons ? ${name} then
            throw "firefox-addons.${name} already exists"
          else
            addon) {
              purple-private-windows = buildFirefoxXpiAddon {
                pname = "purple-private-windows";
                version = "1.1";
                addonId = "purplePrivateWindows@waldemar.b";
                url =
                  "https://addons.mozilla.org/firefox/downloads/file/3423600/purple_private_windows-1.1.xpi";
                sha256 = "sha256-FMu5tY7PwPTpUzrnbK2igfJhSCKUb1OMSPIhjIBwLok=";
                meta = { };
              };
            });
      };
  };
}
