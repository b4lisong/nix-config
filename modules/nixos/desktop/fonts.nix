{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = false;
    fontDir.enable = true;

    packages = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome

      noto-fonts-emoji

      nerd-fonts.symbols-only
      nerd-fonts.sauce-code-pro

      julia-mono
      dejavu_fonts
    ];

    # user defined fonts
    # Noto Color Emoji is present everywhere to override
    #  DejaVu's B&W emojis showing instead of color emojis
    fontconfig.defaultFonts = {
      monospace = ["SauceCodePro Nerd Font" "Noto Color Emoji"];
      emoji = ["Noto Color Emoji"];
    };
  };
}
