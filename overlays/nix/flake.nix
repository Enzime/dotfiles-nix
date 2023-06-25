{
  inputs.nix.url = "github:NixOS/nix";
  inputs.nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, nix, flake-utils }:
    {
      overlay = final: prev: { nix = nix.packages.${prev.system}.default; };
    } // (flake-utils.lib.eachDefaultSystem (system: {
      packages.nix = (import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      }).nix;

      packages.default = self.packages.${system}.nix;
    }));
}
