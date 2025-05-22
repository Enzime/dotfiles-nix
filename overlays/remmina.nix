self: super: {
  remmina = super.remmina.overrideAttrs (old: {
    cmakeFlags =
      assert !super.lib.any (super.lib.hasPrefix "-DPYTHON_INCLUDE_DIR=")
        old.cmakeFlags;
      old.cmakeFlags ++ [
        "-DPYTHON_INCLUDE_DIR=${super.python3}/include/${super.python3.libPrefix}"
        "-DPYTHON_LIBRARY=${super.python3}/lib/libpython${super.python3.pythonVersion}${super.hostPlatform.extensions.sharedLibrary}"
      ];

    preFixup = assert !super.lib.hasInfix "--prefix PATH " old.preFixup;
      old.preFixup + ''
        gappsWrapperArgs+=(
          --prefix PATH : "${super.lib.makeBinPath [ super.python3 ]}"
        )
      '';
  });
}
