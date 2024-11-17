{pkgs, ...}: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    # Define fonts

    # icon fonts
    material-design-icons
    font-awesome

    # emoji fonts
    noto-fonts-emoji

    # other fonts
    source-sans
    source-serif

    # nerdfonts
    (nerdfonts.override {
      fonts = [
        # symbols only
        "NerdFontsSymbolsOnly"
        # characters
        "FiraCode"
        "JetBrainsMono"
        "Iosevka"
      ];
    })
    julia-mono
    dejavu_fonts
  ];
}
