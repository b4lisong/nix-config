{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.vim
  ];

  nix.settings.experimental-features = "nix-command flakes";
}
