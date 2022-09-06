{
  inputs.nix.url = github:NixOS/nix;
  inputs.nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = { self, nixpkgs, nix, flake-utils }: {
    overlay = final: prev: {
      nix = nix.packages.${prev.system}.default.overrideAttrs (old: {
        # WORKAROUND: When overriding Nix on Darwin, Nix throws a disallowed reference to boost error
        #             https://github.com/NixOS/nix/pull/5915
        disallowedReferences = if prev.stdenv.hostPlatform.isDarwin then [ ] else old.disallowedReferences;

        version = "${old.version}-dirtier";

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
