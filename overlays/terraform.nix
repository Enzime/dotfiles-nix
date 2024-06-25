self: super: {
  terraform-providers = super.terraform-providers // (super.lib.mapAttrs
    (name: plugin:
      if super.terraform-providers ? ${name} then
        throw "terraform-providers.${name} already exists"
      else
        plugin) {
          onepassword = super.terraform-providers.mkProvider
            (let version = "2.1.0";
            in {
              inherit version;
              owner = "1Password";
              repo = "terraform-provider-onepassword";
              rev = "v${version}";
              hash = "sha256-rdS9Udzfc/U7E4CIyySnntOCVBBZL0/GuAiVCI5uMrc=";
              vendorHash = null;
              provider-source-address =
                "registry.terraform.io/1Password/onepassword";
              spdx = "MIT";
            });
        });
}
