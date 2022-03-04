self: super: {
  # Taken with love from https://github.com/hyperfekt/nix-exp/blob/19ed40af9f03f74faafc397fe99169cd37315494/config/bcachefs-support.nix#L16-L20
  # Rely on bcachefs-tools to do the version check
  # as it is not easy to test the bcachefs kernel version
  linuxKernel = assert (self.bcachefs-tools.meta.available); super.lib.recursiveUpdate super.linuxKernel {
    kernels.linux_testing_bcachefs = super.linuxKernel.kernels.linux_testing_bcachefs.override {
      date = "2021-12-26";
      commit = "b034dfb24fece43a7677b9a29781495aeb62767f";
      diffHash = "0m7qrnfrcx3dki9lmsq3jk3mcrfm99djh83gwwjh401ql0cycx5p";
    };
  };
  bcachefs-tools = super.bcachefs-tools.overrideAttrs (old: assert (
    super.lib.hasSuffix "2022-01-12" old.version
  ); {
    version = "unstable-2021-12-25";

    src = super.fetchFromGitHub {
      owner = "koverstreet";
      repo = "bcachefs-tools";
      rev = "07b18011cc885f0ef5cadc299d0321322f442388";
      sha256 = "sha256-/u/bx3Jm5TTmFsSzeXp3aVh4tsvPfx2dCrwAqpVcbXs=";
    };
  });
}
