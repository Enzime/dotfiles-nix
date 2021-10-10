{ config, pkgs, ... }:

{
  # FUTURE: remove these lines when `nix flakes` is stable one day hopefully
  nix.package = (assert pkgs.nix != pkgs.nixFlakes; pkgs.nixFlakes);
  nix.extraOptions = (assert pkgs.nix != pkgs.nixFlakes; ''
    experimental-features = nix-command flakes
  '');

  system.extraSystemBuilderCmds = "ln -sv ${./.} $out/dotfiles";

  time.timeZone = "Australia/Melbourne";
  i18n.defaultLocale = "en_AU.UTF-8";

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs) wget ranger firefox;
  };

  programs.zsh.enable = true;
  programs.neovim.enable = true;
  programs.neovim.vimAlias = true;

  # Setting `useDHCP` globally is deprecated
  # manually set `useDHCP` for individual interfaces
  networking.useDHCP = false;

  services.openssh.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # On first setup, run `nixos-enter` then `passwd enzime`.
  users.users.enzime = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };
}
