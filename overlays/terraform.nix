self: super: {
  terraform-providers = super.terraform-providers // (super.lib.mapAttrs
    (name: plugin:
      if super.terraform-providers ? ${name} then
        throw "terraform-providers.${name} already exists"
      else
        plugin) {
          onepassword = super.terraform-providers.mkProvider
            (let version = "1.4.0";
            in {
              inherit version;
              owner = "1Password";
              repo = "terraform-provider-onepassword";
              rev = "v${version}";
              hash = "sha256-+zusrzMZqoPsSIv2Dh2IEkFd17HVDrVj2wp5th4rRjk=";
              vendorHash = null;
              provider-source-address =
                "registry.terraform.io/1Password/onepassword";
              spdx = "MIT";
            });
        });
}
