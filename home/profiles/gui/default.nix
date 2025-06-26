{pkgs, ...}: {
  imports = [
    ../tui
    ../../modules/terminal/kitty.nix
  ];

  home.packages = with pkgs; [
    # TODO: define more gui packages
  ];
}
