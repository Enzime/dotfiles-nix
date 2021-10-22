{
  inputs.nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.inheritedNix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = { self, nixpkgs, inheritedNix, nix, flake-utils }: {
    overlay = final: prev: {
      nixFlakes = assert (builtins.compareVersions prev.nix.version "2.4") < 0; prev.nixFlakes.overrideAttrs (old:
        # `inheritedNix` and `nix` should always have the same NAR hash
        # except when `inheritedNix` is overridden using `--override-input nix ...`
        if (inheritedNix.narHash != nix.narHash) then {
          version = "${old.version}-dirtiest";

          src = inheritedNix;
        } else {
          version = "${old.version}-dirtier";

          patches = old.patches ++ [
            (prev.fetchpatch {
              name = "add-dirtyRev-and-dirtyShortRev-to-fetchGit.patch";
              url = "https://patch-diff.githubusercontent.com/raw/NixOS/nix/pull/5385.patch";
              sha256 = "sha256-50qV1srrwbCICgY9XRvX7EHpU1ZtdXE8jkCgy5QeMh0=";
            })
          ];
        }
      );
    };
  } // (
    flake-utils.lib.eachDefaultSystem (system: {
      packages.nixFlakes = (import nixpkgs { inherit system; overlays = [ self.overlay ]; }).nixFlakes;

      defaultPackage = self.packages.${system}.nixFlakes;
    })
  );
}
