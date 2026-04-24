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
      go-gitea_gitea = super.terraform-providers.go-gitea_gitea.override (
        old:
        assert old.rev == "v0.7.0";
        {
          owner = "gitea";
          repo = "terraform-provider-gitea";
          rev = "7c771be11041c1ab625bfc68d8f1fb16a5fa1514";
          version = "0.8.0";
          hash = "sha256-L14lXHwLPUg+3DCRPnO1RJRCH2aKTu3FQSTqEEDc92A=";
          vendorHash = "sha256-NQXqzEXjX1kAHD0DjoQVP6DAdLmeOG005criUTL8gSQ=";
          mkProviderFetcher = args: super.fetchFromGitea (args // { domain = "gitea.com"; });
        }
      );
    };

  terragrunt = super.terragrunt.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        name = "support-s3-endpoints.patch";
        url = "https://github.com/gruntwork-io/terragrunt/commit/d679c86b86049c3150ac26156bf1616aeeab555b.patch";
        hash = "sha256-oUdxwBkALtqoV6EPD+nSLaCurGY4XIf6kmWWTX746cE=";
      })
    ];
  });
}
