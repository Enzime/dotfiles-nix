{
  inputs.nix.url = "github:NixOS/nix";
  inputs.nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, nix, flake-utils }: {
    overlay = final: prev: {
      nix = nixpkgs.legacyPackages.${prev.system}.nix.overrideAttrs (old: {
        version = "${old.version}-dirtier";

        src = nix;

        patches = (old.patches or [ ]) ++ [
          (prev.fetchpatch {
            name = "add-dirtyRev-and-dirtyShortRev-to-fetchGit.patch";
            url = "https://patch-diff.githubusercontent.com/raw/NixOS/nix/pull/5385.patch";
            sha256 = "sha256-zDnnty9ScICGB/H9EQsbjCFvp70Fbpa0+UnxouxTUxI=";
          })
        ];
      });
    };
  } // (
    flake-utils.lib.eachDefaultSystem (system: {
      packages.nix = (import nixpkgs { inherit system; overlays = [ self.overlay ]; }).nix;

      packages.default = self.packages.${system}.nix;
    })
  );
}
