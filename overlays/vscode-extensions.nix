self: super:

let
  inherit (super.lib) hasAttrByPath recursiveUpdate;
  inherit (super.vscode-utils) buildVscodeMarketplaceExtension;
in {
  vscode-extensions = recursiveUpdate super.vscode-extensions {
    # The `assert` ensures that the extension isn't already present in `nixpkgs`
    asvetliakov.vscode-neovim = (assert (!hasAttrByPath ["asvetliakov" "vscode-neovim"] super.vscode-extensions); buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "vscode-neovim";
        publisher = "asvetliakov";
        version = "0.0.82";
        sha256 = "17f0jzg9vdbqdjnnc5i1q28ij2kckvvxi7fw9szmyy754f074jb1";
      };
    });

    kamikillerto.vscode-colorize = (assert (!hasAttrByPath ["kamikillerto" "vscode-colorize"] super.vscode-extensions); buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "vscode-colorize";
        publisher = "kamikillerto";
        version = "0.11.1";
        sha256 = "1h82b1jz86k2qznprng5066afinkrd7j3738a56idqr3vvvqnbsm";
      };
    });
  };
}
