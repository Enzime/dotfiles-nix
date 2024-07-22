self: super: {
  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (self': super': {
      pyasn1-modules = super'.pyasn1-modules.overridePythonAttrs (old:
        let version = "0.4.0";
        in assert builtins.compareVersions old.version version == -1; {
          inherit version;
          format = null;
          pyproject = true;

          src = super.fetchFromGitHub {
            owner = "pyasn1";
            repo = "pyasn1-modules";
            rev = "refs/tags/v${version}";
            hash = "sha256-UJycVfj08+3zjHPji5Qlh3yqeS30dEwu1pyrN1yo1Vc=";
          };

          build-system = [ super'.setuptools ];

          dependencies = [ super'.pyasn1 ];
        });
    })
  ];
}
