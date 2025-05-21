{ self-lib, ... }:
let inherit (self-lib) modules;
in {
  imports = map self-lib.mkConfiguration [
    {
      host = "hyperion";
      hostSuffix = "-macos";
      user = "enzime";
      system = "aarch64-darwin";
      modules =
        builtins.attrNames { inherit (modules) android laptop personal; };
    }
    {
      host = "phi";
      hostSuffix = "-nixos";
      user = "enzime";
      system = "x86_64-linux";
      modules = builtins.attrNames {
        inherit (modules)
          android bluetooth deluge nextcloud personal printers samba scanners
          sway wireless virt-manager;
      };
    }
    {
      host = "sigma";
      user = "enzime";
      system = "x86_64-linux";
      modules = builtins.attrNames {
        inherit (modules) impermanence laptop personal sway;
      };
    }
    {
      host = "eris";
      user = "human";
      system = "x86_64-linux";
      modules =
        builtins.attrNames { inherit (modules) deluge reflector vncserver; };
    }
  ];
}
