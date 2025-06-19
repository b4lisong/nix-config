{pkgs, ...}: {
  home.packages = with pkgs; [
    spotify
    signal-desktop-bin
    gimp-with-plugins
  ];
}
