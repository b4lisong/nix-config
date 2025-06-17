{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.vim
  ];

  # Define a minimum set of fonts for all systems
  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
    nerd-fonts.symbols-only
    font-awesome
    material-design-icons
    noto-fonts-emoji
    dejavu_fonts
  ];

  nix.settings.experimental-features = "nix-command flakes";
}
