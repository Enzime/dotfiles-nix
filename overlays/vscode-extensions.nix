self: super:

let
  inherit (super.lib) hasAttrByPath recursiveUpdate;
  inherit (super.vscode-utils) buildVscodeMarketplaceExtension;
in {
  vscode-extensions = recursiveUpdate super.vscode-extensions {
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
