self: super: {
  python3Packages = super.lib.recursiveUpdate super.python3Packages {
    identify = super.python3Packages.identify.overrideAttrs (old: {
      src = super.fetchFromGitHub {
        owner = "Enzime";
        repo = "identify";
        rev = "0cbe036928d3ba099a397c41a6b0ce3474355c54";
        hash = "sha256-fOEKHFq3t7lnDmBOyEmG/SooaMipFw05p5x5R9uvEUA=";
      };
    });
  };
}
