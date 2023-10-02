self: super:

let
  inherit (super.lib)
    foldl getAttrFromPath getVersion hasAttrByPath recursiveUpdate splitString;
  inherit (super.vscode-utils) extensionsFromVscodeMarketplace;

  attrsetFromPathValue = { path, value, start ? 0 }:

    if start == builtins.length path then
      value
    else {
      ${builtins.elemAt path start} = attrsetFromPathValue {
        inherit path value;
        start = start + 1;
      };
    };

  attrsetFromDottedPathValue = path: value:
    attrsetFromPathValue {
      path = splitString "." path;
      inherit value;
    };

  compareVersions = a: b:
    builtins.compareVersions (getVersion a) (getVersion b);

  ensureNotOutdatedExtension = ext:
    let
      path = splitString "." ext.vscodeExtUniqueId;

      alreadyInNixpkgs = hasAttrByPath path super.vscode-extensions;
    in if alreadyInNixpkgs
    && compareVersions ext (getAttrFromPath path super.vscode-extensions)
    != 1 then
      throw
      "vscode-extensions.${ext.vscodeExtUniqueId} is older than the version in Nixpkgs"
    else
      ext;

  extensionToAttrset = ext:
    attrsetFromDottedPathValue ext.vscodeExtUniqueId
    (ensureNotOutdatedExtension ext);

  extensionsAttrsetFromList = extensions:
    foldl recursiveUpdate { } (map extensionToAttrset extensions);
  fromMarketplaceRefs = mktplcRefs:
    extensionsAttrsetFromList (extensionsFromVscodeMarketplace mktplcRefs);
in {
  vscode-extensions = recursiveUpdate (recursiveUpdate super.vscode-extensions {
    ms-vscode-remote.remote-ssh =
      super.vscode-extensions.ms-vscode-remote.remote-ssh.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace "out/extension.js" \
            --replace "wget --no-proxy" "wget --no-proxy --no-continue"
        '';
      });
  }) (fromMarketplaceRefs [
    {
      name = "comment-tagged-templates";
      publisher = "bierner";
      version = "0.3.1";
      sha256 = "sha256-dJyc7txc3fSlNWNGx2G8yF0hObYaiE2c44vzMrvzdkE=";
    }
    {
      name = "markdown-preview-github-styles";
      publisher = "bierner";
      version = "1.0.1";
      sha256 = "sha256-UhWbygrGh0whVxfGcEa+hunrTG/gfHpXYii0E7YhXa4=";
    }
  ]);
}
