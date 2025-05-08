self: super: {
  _1password-gui = super._1password-gui.overrideAttrs (old: {
    meta = assert old.meta.broken == super.stdenv.hostPlatform.isDarwin;
      old.meta // {
        broken = false;
      };
  });
}
