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
        version = "0.0.83";
        sha256 = "1giybf12p0h0fm950w9bwvzdk77771zfkylrqs9h0lhbdzr92qbl";
      };
    });

    ethansk.restore-terminals = (assert (!hasAttrByPath ["ethansk" "restore-terminals"] super.vscode-extensions); buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "restore-terminals";
        publisher = "ethansk";
        version = "1.1.6";
        sha256 = "1j58sia9s89p43rgcnjic6lygihs452ahzw4wjygq9y82nk32a2w";
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

    rioj7.commandOnAllFiles = (assert (!hasAttrByPath ["rioj7" "commandOnAllFiles"] super.vscode-extensions); buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "commandOnAllFiles";
        publisher = "rioj7";
        version = "0.3.0";
        sha256 = "04f1sb5rxjwkmidpymhqanv8wvp04pnw66098836dns906p4gldl";
      };
    });

    shardulm94.trailing-spaces = (assert (!hasAttrByPath ["shardulm94" "trailing-spaces"] super.vscode-extensions); buildVscodeMarketplaceExtension {
      mktplcRef = {
        publisher = "shardulm94";
        name = "trailing-spaces";
        version = "0.3.1";
        sha256 = "0h30zmg5rq7cv7kjdr5yzqkkc1bs20d72yz9rjqag32gwf46s8b8";
      };
    });
  };
}
