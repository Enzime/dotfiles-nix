self: super: {
  zellij = super.zellij.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        name = "add-tmux-session-manager-keybinding.patch";
        url =
          "https://github.com/Enzime/zellij/commit/7f4d1e773cb26ab1b0e3800f9d7f90245adbe596.patch";
        hash = "sha256-JCbcwXTd6SXmSuZtf7m+3NdVhJoOxUM6JS2xozGkSpg=";
        excludes = [ "**/*.snap" ];
      })
      (super.fetchpatch {
        name = "fix-tmux-ctrl-b-o-not-returning-to-normal-mode.patch";
        url =
          "https://github.com/Enzime/zellij/commit/a9bea4570f728f08dff631067ab11445d777be6a.patch";
        hash = "sha256-0Iyc+l1GhyDxjei3RQdC2MPepMnEjD3mVYbxPfoYk38=";
        excludes = [ "**/*.snap" ];
      })
      (super.fetchpatch {
        name = "fix-tmux-ctrl-b-space-not-returning-to-normal-mode.patch";
        url =
          "https://github.com/Enzime/zellij/commit/307aa4dff818e4c5808384e6e60250368e00f253.patch";
        hash = "sha256-MjrUI//hq49wcyyuJ5CtUiMqaLGKhlBTz/rXw2qUAMA=";
        excludes = [ "**/*.snap" ];
      })
      (super.fetchpatch {
        name = "report-osc52.patch";
        url =
          "https://github.com/Enzime/zellij/commit/60acd439985339e518f090821c0e4eb366ce6014.patch";
        hash = "sha256-hG1VEtydGy3Q9vL2pL/lVEWidq5OcWQWLXay5HpvU7s=";
      })
    ];
  });
}
