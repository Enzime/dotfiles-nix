{
  inputs.nix.url = "github:NixOS/nix";
  inputs.nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, nix, flake-utils }:
    {
      # WORKAROUND: 2.18.1 doesn't build with a newer Nixpkgs, use 2.18.1 from Nixpkgs
      # 2.19+ can't be used currently due to https://github.com/NixOS/nix/issues/9579
      overlay = final: prev: {
        nix = assert nix.packages.${prev.system}.default.version == "2.18.1";
          nixpkgs.legacyPackages.${prev.system}.nixVersions.nix_2_18;
      };
    } // (flake-utils.lib.eachDefaultSystem (system: {
      packages.nix = (import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      }).nix;

      packages.default = self.packages.${system}.nix;
    }));
}
