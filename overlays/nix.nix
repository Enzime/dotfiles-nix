self: super: {
  # Ensure that the current stable version of Nix is not yet 2.4
  nixFlakes = (assert (builtins.compareVersions super.nix.version "2.4") < 0; super.nixFlakes.overrideAttrs (old: {
    version = "${old.version}-dirtier";

    patches = old.patches ++ [ (super.fetchpatch {
      name = "add-dirtyRev-and-dirtyShortRev-to-fetchGit.patch";
      url = "https://github.com/Enzime/nix/commit/f0a84fba74b9e8e83c9778d4aa0e2641241ebc0d.patch";
      sha256 = "sha256-TaVlwmI4mra7h8m6vkqUpGfDqmrMCvm1hdK99f8gNKE=";
    }) ];
  }));
}
