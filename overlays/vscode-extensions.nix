self: super:

let
  inherit (super.lib) getVersion hasAttrByPath recursiveUpdate versionOlder;
  inherit (super.vscode-utils) buildVscodeMarketplaceExtension;
in {
  vscode-extensions = recursiveUpdate super.vscode-extensions {
    # Only override if version in `nixpkgs` is older
    asvetliakov.vscode-neovim = (assert versionOlder (getVersion super.vscode-extensions.asvetliakov.vscode-neovim) "0.0.83"; buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "vscode-neovim";
        publisher = "asvetliakov";
        version = "0.0.83";
        sha256 = "1giybf12p0h0fm950w9bwvzdk77771zfkylrqs9h0lhbdzr92qbl";
      };
    });

    # The `assert` ensures that the extension isn't already present in `nixpkgs`
    ethansk.restore-terminals = (assert (!hasAttrByPath ["ethansk" "restore-terminals"] super.vscode-extensions); buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "restore-terminals";
        publisher = "ethansk";
        version = "1.1.6";
        sha256 = "1j58sia9s89p43rgcnjic6lygihs452ahzw4wjygq9y82nk32a2w";
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
  };
}
