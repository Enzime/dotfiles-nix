self: super: {
  joplin-desktop = super.joplin-desktop.overrideAttrs (old: {
    postFixup = assert !super.lib.hasInfix "7za" (old.postFixup or "");
      (old.postFixup or "") + (if super.stdenv.hostPlatform.isDarwin then ''
        chmod a+x $out/Applications/Joplin.app/Contents/Resources/build/7zip/7za
      '' else ''
        chmod a+x $out/share/joplin-desktop/resources/build/7zip/7za
      '');
  });
}
