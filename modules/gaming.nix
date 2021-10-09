{
  nixosModule = { ... }: {
    services.xserver.inputClassSections = [ ''
      Identifier    "CTL-472"
      MatchProduct  "Wacom One"
      Option        "TransformationMatrix" "0.4463039007311721 0 0.3095532576023331 0 0.9433962264150944 0.03966763902681231 0 0 1"
    '' ];
  };

  hmModule = { pkgs, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) steam multimc lutris discord;
    };
  };
}
