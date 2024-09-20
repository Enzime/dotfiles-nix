self: super: {
  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (self': super': {
      berkeleydb = super'.berkeleydb.overridePythonAttrs
        (old: { doCheck = assert !old ? doCheck; !super.stdenv.isDarwin; });
    })
  ];
}
