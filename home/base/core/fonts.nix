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
    # after 25.05
    nerd-fonts.symbols-only
    nerd-fonts.sauce-code-pro
    # before 25.05
    #(nerdfonts.override {
    #  fonts = [
    #    # symbols only
    #    "NerdFontsSymbolsOnly"
    #    # characters
    #    "SourceCodePro"
    #  ];
    #}
    julia-mono
    dejavu_fonts
  ];
}
