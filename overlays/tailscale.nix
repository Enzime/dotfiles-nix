self: super: {
  tailscale = super.tailscale.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        name = "support-exit-nodes-on-macos.patch";
        url = "https://github.com/Enzime/tailscale/commit/2de687882bd4480ad538fb613ead1fb5339b6a00.patch";
        hash = "sha256-xTQ4pbcj0AhTYfJMQSho6Mxf42bOCQuymiFKm+8Y07A=";
      })
    ];
  });
}
