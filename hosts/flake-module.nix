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
        builtins.attrNames { inherit (modules) ai android laptop personal; };
    }
    {
      host = "phi";
      hostSuffix = "-nixos";
      user = "enzime";
      system = "x86_64-linux";
      modules = builtins.attrNames {
        inherit (modules)
          android bluetooth deluge nextcloud personal printers restic samba
          scanners sway wireless virt-manager;
      };
      tags = [ "wireless-personal" ];
    }
    {
      host = "sigma";
      user = "enzime";
      system = "x86_64-linux";
      modules = builtins.attrNames {
        inherit (modules) impermanence laptop personal sway;
      };
      tags = [ "wireless-personal" ];
    }
    {
      host = "eris";
      user = "human";
      system = "x86_64-linux";
      modules =
        builtins.attrNames { inherit (modules) deluge reflector vncserver; };
    }
    {
      host = "gaia";
      user = "enzime";
      system = "x86_64-linux";
      modules = builtins.attrNames {
        inherit (modules) hoopsnake impermanence vncserver;
      };
    }
  ];

  clan = {
    inventory.instances = {
      wifi = {
        roles.default.machines.phi-nixos.settings.networks = {
          home.autoConnect = false;
          hotspot.autoConnect = false;
          jaden.autoConnect = false;
        };
      };
    };
  };
}
