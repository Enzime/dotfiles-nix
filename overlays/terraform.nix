self: super: {
  terraform-providers =
    super.terraform-providers
    // (super.lib.mapAttrs
      (
        name: plugin:
        if super.terraform-providers ? ${name} then
          throw "terraform-providers.${name} already exists"
        else
          plugin
      )
      {
        valodim_desec = super.terraform-providers.mkProvider (
          let
            version = "0.6.1";
            owner = "Valodim";
            pname = "desec";
          in
          {
            inherit owner version;
            repo = "terraform-provider-${pname}";
            rev = "v${version}";
            hash = "sha256-+uOXwta9/Fq9SnW66HfgpIEGtc2qelfLYSIUdyAnmfY=";
            vendorHash = "sha256-z6J9ivGBk60y/ICGV2D4tQpBOz0y2O9lHDaqXy5zf1I=";
            provider-source-address = "registry.terraform.io/${owner}/${pname}";
            spdx = "MIT";
          }
        );
      }
    )
    // {
      "1password_onepassword" = super.terraform-providers."1password_onepassword".override (old: {
        rev = "v2.2.1";
        hash = "sha256-1wi+SO0yKrlTWtUOQfcISGAAFHfddtsGhDaBD/7aYQg=";
        vendorHash = "sha256-mTcvQC2MMnjr27P3UrTpQcHD0pWOC3vwKkHGJlnfFaU=";
      });
    };

  opentofu = super.opentofu.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        name = "fix-upgrade-with-nix.patch";
        url = "https://github.com/opentofu/opentofu/commit/99f8c6a9c2ec1a3b54fe39dee4c021984f9b5798.patch";
        hash = "sha256-H5IWpnBeIqgQXeVfcb+0b+EnMtjQyBhnN99EIP7zMLg=";
      })
    ];
  });
}
