{ config, configRevision, pkgs, ... }:

{
  # Ensure that the current stable version of Nix is not yet 2.4
  nix.package = (assert (builtins.compareVersions pkgs.nix.version "2.4") < 0; pkgs.nixFlakes);
  nix.extraOptions = (assert (builtins.compareVersions pkgs.nix.version "2.4") < 0; ''
    experimental-features = nix-command flakes
  '');

  # Add flake revision to `nixos-version --json`
  system.configurationRevision = configRevision.full;

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
