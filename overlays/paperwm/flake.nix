{
  inputs.paperwm.url = github:paperwm/paperwm/next-release;
  inputs.paperwm.flake = false;

  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = { self, nixpkgs, paperwm, flake-utils }: {
    overlay = final: prev: {
      gnomeExtensions = prev.lib.recursiveUpdate prev.gnomeExtensions {
        paperwm = prev.gnomeExtensions.paperwm.overrideAttrs (old:
          let
            version = "pre-40.0";
          in {
            inherit version;
            name = "${old.pname}-${version}";

            src = paperwm;
          }
        );
      };
    };
  } // (
    flake-utils.lib.eachDefaultSystem (system: {
      packages."gnomeExtensions/paperwm" = (import nixpkgs { inherit system; overlays = [ self.overlay ]; }).gnomeExtensions.paperwm;

      packages.default = self.packages.${system}."gnomeExtensions/paperwm";
    })
  );
}
