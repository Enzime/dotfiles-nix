self: super: {
  remmina = assert !super.remmina.override.__functionArgs ? withWebkitGtk;
    super.remmina.overrideAttrs (old: {
      buildInputs =
        builtins.filter (pkg: pkg.pname != "webkitgtk") old.buildInputs;
      cmakeFlags = old.cmakeFlags ++ [ "-DWITH_WEBKIT2GTK=OFF" ];
    });
}
