{
  nixosModule = { ... }: {
    services.synergy.server.enable = true;
    services.synergy.server.tls.enable = true;

    networking.firewall.allowedTCPPorts = [ 24800 ];

    environment.etc."synergy-server.conf" = {
      text = ''
        section: screens
            phi:
            upsilon:
              alt = super
              super = alt
        end
        section: aliases
            phi:
                phi-nixos
        end
        section: links
            phi:
                left = upsilon
            upsilon:
                right = phi
        end
      '';
    };
  };
}
