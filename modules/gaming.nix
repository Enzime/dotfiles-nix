{
  imports = [ "personal" ];

  nixosModule = {
    services.xserver.inputClassSections = [''
      Identifier    "CTL-472"
      MatchProduct  "Wacom One"
      Option        "TransformationMatrix" "0.5381253317409767 0 0.02466001733346604 0 1.1986436400914755 0.11744785505874931 0 0 1"
    ''];

    programs.steam.enable = true;
  };

  homeModule = { pkgs, ... }: {
    home.packages =
      builtins.attrValues { inherit (pkgs) lutris prismlauncher; };
  };
}
