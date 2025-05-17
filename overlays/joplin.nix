self: super: {
  joplin-desktop = if super.hostPlatform.isLinux then
    super.joplin-desktop
  else
    super.joplin-desktop.overrideAttrs (old: {
      postPatch = assert !super.lib.hasInfix "7za" (old.postPatch or "");
        (old.postPatch or "") + ''
          chmod a+x Joplin.app/Contents/Resources/build/7zip/7za
        '';
    });
}
