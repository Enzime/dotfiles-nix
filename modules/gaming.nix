{
  imports = [ "personal" ];

  nixosModule = {
    programs.steam.enable = true;
  };

  homeModule = {
    programs.lutris.enable = true;

    preservation = {
      directories = [
        ".steam"
        ".local/share/steam"
        ".local/share/lutris"
      ];
    };
  };
}
