{
  inputs.nix.url = github:NixOS/nix;
  inputs.nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = { self, nixpkgs, nix, flake-utils }: {
    overlay = final: prev: {
      nix = nix.defaultPackage.${prev.system}.overrideAttrs (old: {
        version = "${old.version}-dirtier";

        patches = (old.patches or [ ]) ++ [
          (prev.fetchpatch {
            name = "add-dirtyRev-and-dirtyShortRev-to-fetchGit.patch";
            url = "https://patch-diff.githubusercontent.com/raw/NixOS/nix/pull/5385.patch";
            sha256 = "sha256-KVXTpSRIsgvyisJeWMan1fUWgyGpx17mUGZjE+QVPbI=";
          })
        ];
      });
    };
  } // (
    flake-utils.lib.eachDefaultSystem (system: {
      packages.nix = (import nixpkgs { inherit system; overlays = [ self.overlay ]; }).nix;

      defaultPackage = self.packages.${system}.nix;
    })
  );
}
