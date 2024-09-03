{
  inputs.nix.url = "github:NixOS/nix";
  inputs.nix.inputs.flake-compat.follows = "flake-compat";
  inputs.nix.inputs.flake-parts.follows = "flake-parts";
  inputs.nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix.inputs.nixpkgs-regression.follows = "empty";
  inputs.nix.inputs.nixpkgs-23-11.follows = "empty";
  inputs.nix.inputs.git-hooks-nix.follows = "git-hooks";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.flake-compat.url = "github:nix-community/flake-compat";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.git-hooks.url = "github:cachix/git-hooks.nix";

  outputs = { self, nixpkgs, nix, flake-utils, empty, ... }:
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
