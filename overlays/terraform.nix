self: super: {
  terraform-providers = super.terraform-providers // (super.lib.mapAttrs
    (name: plugin:
      if super.terraform-providers ? ${name} then
        throw "terraform-providers.${name} already exists"
      else
        plugin) {
          valodim_desec = super.terraform-providers.mkProvider (let
            version = "0.6.1";
            owner = "Valodim";
            pname = "desec";
          in {
            inherit owner version;
            repo = "terraform-provider-${pname}";
            rev = "v${version}";
            hash = "sha256-+uOXwta9/Fq9SnW66HfgpIEGtc2qelfLYSIUdyAnmfY=";
            vendorHash = "sha256-z6J9ivGBk60y/ICGV2D4tQpBOz0y2O9lHDaqXy5zf1I=";
            provider-source-address = "registry.terraform.io/${owner}/${pname}";
            spdx = "MIT";
          });
        });

  terragrunt = super.terragrunt.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        name = "support-s3-endpoints.patch";
        url =
          "https://github.com/gruntwork-io/terragrunt/commit/75e10069932050bd52912a027ea3e53b507bbbd3.patch";
        hash = "sha256-I5HLv893ZmL8t19PPrwFrzfJgUcw72UdGEFOY0iXZHk=";
      })
    ];
  });
}
