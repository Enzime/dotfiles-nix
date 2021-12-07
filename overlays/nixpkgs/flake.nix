{
  inputs.unstable.url = github:NixOS/nixpkgs/nixos-unstable;

  outputs = { self, unstable }: {
    overlay = final: prev: {
      mpv = unstable.legacyPackages.x86_64-linux.mpv;
      neovim = unstable.legacyPackages.x86_64-linux.neovim;
      nix-direnv = unstable.legacyPackages.x86_64-linux.nix-direnv;
    };
  };
}
