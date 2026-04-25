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
      go-gitea_gitea =
        (super.terraform-providers.go-gitea_gitea.override (
          old:
          assert old.rev == "v0.7.0";
          {
            owner = "gitea";
            repo = "terraform-provider-gitea";
            rev = "7c771be11041c1ab625bfc68d8f1fb16a5fa1514";
            version = "0.8.0";
            hash = "sha256-L14lXHwLPUg+3DCRPnO1RJRCH2aKTu3FQSTqEEDc92A=";
            proxyVendor = true;
            vendorHash = "sha256-TezGIhbyZY+moXEzQVqdys9R7URlUZzMFy3OjRYHZBA=";
            mkProviderFetcher = args: super.fetchFromGitea (args // { domain = "gitea.com"; });
          }
        )).overrideAttrs
          (prev: {
            patches = (prev.patches or [ ]) ++ [
              (super.fetchpatch {
                name = "configure-admin-bypass.patch";
                url = "https://gitea.com/Enzime/terraform-provider-gitea/commit/47a1d5cf017e12b2c5183f043201d8bd17461035.patch";
                hash = "sha256-PQaSx/8u/7cG7QIgZ7V7JdFu/ClADMHvhv88LYE+fcI=";
              })
            ];

            postPatch = ''
              echo 'replace code.gitea.io/sdk/gitea => gitea.com/Enzime/go-sdk/gitea v0.24.2-0.20260424234109-469754782127' >> go.mod
              echo 'gitea.com/Enzime/go-sdk/gitea v0.24.2-0.20260424234109-469754782127 h1:KArANW8MQFd9KogV/v2LDSeceCQZhJ6rGvSXfbrXOSQ=' >> go.sum
              echo 'gitea.com/Enzime/go-sdk/gitea v0.24.2-0.20260424234109-469754782127/go.mod h1:uDFWYBU8dgZsgOHwe6C/6olxvf8FHguNB3wW1i83fgg=' >> go.sum
            '';

            env = prev.env // {
              GOFLAGS = prev.env.GOFLAGS + " -mod=mod";
            };

            passthru.overrideModAttrs = final': prev': {
              preBuild = (prev'.preBuild or "") + ''
                GOFLAGS="-mod=mod" go mod tidy
              '';
            };
          });
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

  opentofu = super.opentofu.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        name = "fix-upgrade-with-nix.patch";
        url = "https://github.com/opentofu/opentofu/commit/e763cd121ff58aa504e9c8b2515e30c26df026a8.patch";
        hash = "sha256-jQPssSFA4/zs+EGngGg+dT/J7KWLdSrtjOYEtEWPIJg=";
      })
    ];
  });
}
