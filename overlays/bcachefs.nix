self: super: {
  # Taken with love from https://github.com/hyperfekt/nix-exp/blob/19ed40af9f03f74faafc397fe99169cd37315494/config/bcachefs-support.nix#L16-L20
  # Rely on bcachefs-tools to do the version check
  # as it is not easy to test the bcachefs kernel version
  linuxKernel = assert (self.bcachefs-tools.meta.available); super.lib.recursiveUpdate super.linuxKernel {
    kernels.linux_testing_bcachefs = super.linuxKernel.kernels.linux_testing_bcachefs.override {
      date = "2022-03-04";
      commit = "5490c9c529770aa18b2571bd98f5416ed9ae24c6";
      diffHash = "sha256-mH1LIVgNUd4zM3Fk1XJgAmWzETWd7XrI5NiqsVEjXZs=";
    };
  };
  bcachefs-tools = super.bcachefs-tools.overrideAttrs (old: assert (
    super.lib.hasSuffix "2022-01-12" old.version
  ); {
    version = "2022-03-03";

    src = super.fetchFromGitHub {
      owner = "koverstreet";
      repo = "bcachefs-tools";
      rev = "465e90314cc5e6f910933d092c8b0b2965a5c32b";
      sha256 = "sha256-tu6s0PqQ2GTX+TkCxWaRAZuwkaaF27grR2ayRHu1TqY=";
    };
  });
}
