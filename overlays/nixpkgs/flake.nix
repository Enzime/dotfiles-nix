{
  inputs.unstable.url = github:NixOS/nixpkgs/nixos-unstable;

  outputs = { self, unstable }: {
    overlay = final: prev: {
      neovim = unstable.legacyPackages.x86_64-linux.neovim;
    };
  };
}
