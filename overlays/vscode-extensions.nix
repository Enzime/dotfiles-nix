self: super:

let
  inherit (super.lib) foldl getAttrFromPath getVersion hasAttrByPath recursiveUpdate splitString;
  inherit (super.vscode-utils) extensionsFromVscodeMarketplace;

  attrsetFromPathValue = { path, value, start ? 0 }:

  if start == builtins.length path then
    value
  else
    { ${builtins.elemAt path start} = attrsetFromPathValue { inherit path value; start = start + 1; }; };

  attrsetFromDottedPathValue = path: value: attrsetFromPathValue { path = splitString "." path; inherit value; };

  compareVersions = a: b: builtins.compareVersions (getVersion a) (getVersion b);

  ensureNotOutdatedExtension = ext: let
    path = splitString "." ext.vscodeExtUniqueId;

    alreadyInNixpkgs = hasAttrByPath path super.vscode-extensions;
  in
    if alreadyInNixpkgs && compareVersions ext (getAttrFromPath path super.vscode-extensions) != 1 then
      throw "vscode-extensions.${ext.vscodeExtUniqueId} is older than the version in Nixpkgs"
    else
      ext;

  extensionToAttrset = ext: attrsetFromDottedPathValue ext.vscodeExtUniqueId (ensureNotOutdatedExtension ext);

  extensionsAttrsetFromList = extensions: foldl recursiveUpdate { } (map extensionToAttrset extensions);
  fromMarketplaceRefs = mktplcRefs: extensionsAttrsetFromList (extensionsFromVscodeMarketplace mktplcRefs);
in {
  vscode-extensions = recursiveUpdate super.vscode-extensions (fromMarketplaceRefs [
    {
      name = "emojisense";
      publisher = "bierner";
      version = "0.9.0";
      sha256 = "sha256-UqwKVcF0Nh6SWLSgfKDshqxmp6967Jm19RTTUyC/7D4=";
    }
    {
      name = "markdown-checkbox";
      publisher = "bierner";
      version = "0.3.1";
      sha256 = "sha256-HP7Y/QXwlzj07YTaFG3bwPdNwBRpsPCQiB3rabJtp3Q=";
    }
    {
      name = "markdown-emoji";
      publisher = "bierner";
      version = "0.2.1";
      sha256 = "sha256-m8g9xA7KBQrBv7EdJtJEJYcoKNRvZcc4ILR5mcYSj9E=";
    }
    {
      name = "markdown-preview-github-styles";
      publisher = "bierner";
      version = "1.0.1";
      sha256 = "sha256-UhWbygrGh0whVxfGcEa+hunrTG/gfHpXYii0E7YhXa4=";
    }
  ]);
}
