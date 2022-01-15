{
  nixosModule = { ... }: {
    nix.binaryCaches = [ "https://enzime.cachix.org" ];
    nix.binaryCachePublicKeys = [
      "enzime.cachix.org-1:RvUdpEy6SEXlqvKYOVHpn5lNsJRsAZs6vVK1MFqJ9k4="
    ];
  };

  hmModule = { pkgs, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) cachix;
    };
  };
}
