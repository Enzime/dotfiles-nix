self: super: {
  tailscale = super.tailscale.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        name = "support-exit-nodes-on-macos.patch";
        url = "https://github.com/Enzime/tailscale/commit/f417eda370d18792894d336cf1ee576a372cfc85.patch";
        hash = "sha256-JusxAIQ72Uqn6OMcA6xFn8OEqNLrmGZxoDQU6CBPLVs=";
      })
    ];
  });
}
