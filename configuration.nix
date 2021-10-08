{ config, pkgs, ... }:

{
  # FUTURE: remove these lines when `nix flakes` is stable one day hopefully
  nix.package = (assert pkgs.nix != pkgs.nixFlakes; pkgs.nixFlakes);
  nix.extraOptions = (assert pkgs.nix != pkgs.nixFlakes; ''
    experimental-features = nix-command flakes
  '');

  time.timeZone = "Australia/Melbourne";

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs) neovim wget ranger firefox;
  };

  programs.zsh.enable = true;

  services.openssh.enable = true;

  # On first setup, run `nixos-enter` then `passwd enzime`.
  users.users.enzime = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };
}
