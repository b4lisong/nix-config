{pkgs, ...}: {
  home.packages = with pkgs; [
    # browsers
    firefox-devedition
    google-chrome # TODO: ungoogle
  ];
}
