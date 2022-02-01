self: super: {
  linux-firmware = super.linux-firmware.overrideAttrs (old: let
    version = "20211027";
  in {
    inherit version;

    src = super.fetchgit {
      url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
      rev = "refs/tags/${version}";
      sha256 = "sha256-HYGH8bUezqHL1xrdshhafxTCXu8o8RxqdhnlZ08wewM=";
    };

    outputHash = "sha256-LCiqd/Z53VOpiqHAiooNUmGjuvU1QN5ZfsiLK3MLlK4=";
  });
}
