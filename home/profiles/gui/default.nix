{pkgs, ...}: {
  imports = [
    ../tui
    ../../modules/terminal/kitty.nix # Baseline kitty config
  ];

  home.packages = with pkgs; [
    # TODO: define more gui packages
  ];
}
