{ config, ... }:

{
  programs.zsh.envExtra = ''
    export TERMINFO_DIRS=${config.home.profileDirectory}/share/terminfo:/usr/share/terminfo
  '';
}
