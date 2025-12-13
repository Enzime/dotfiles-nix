self: super: {
  tailscale = super.tailscale.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        name = "support-exit-nodes-on-macos.patch";
        url =
          "https://github.com/Enzime/tailscale/commit/bfe7be579c71e3fc4a405a2f47e0d8e518e8fc51.patch";
        hash = "sha256-5oqQnfZUs4Y8iERNHrIFCJ5GYyYgfxax7mEQlfaAIeQ=";
      })
    ];
  });
}
