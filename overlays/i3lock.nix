self: super: {
  i3lock = super.i3lock.override { pam = super.pam.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ (super.fetchpatch {
      name = "use-suid-unix_ckpwd.patch";
      url = "https://raw.githubusercontent.com/vcunat/nixpkgs/ffdadd3ef9167657657d60daf3fe0f1b3176402d/pkgs/os-specific/linux/pam/suid-wrapper-path.patch";
      sha256 = "sha256-Qn26iHqY9DQrVL3myRjUeL1PYPirJWY7R/RYYukW2Ds=";
    }) ];
  }); };
}
