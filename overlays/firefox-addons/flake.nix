{
  inputs.firefox-addons.url =
    "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
  inputs.firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { firefox-addons, nixpkgs, ... }: {
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
        firefox-addons = addons // (let inherit (prev.lib) mapAttrs;
        in mapAttrs (name: addon:
          if addons ? ${name} then
            throw "firefox-addons.${name} already exists"
          else
            addon) { });
      };
  };
}
