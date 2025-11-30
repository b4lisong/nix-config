{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../home/profiles/base
    ../../home/profiles/tui
  ];

  home.homeDirectory = lib.mkForce "/home/balisong";
}
