{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
    nerd-fonts.symbols-only
    font-awesome
    material-design-icons
    noto-fonts-emoji
    dejavu_fonts
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 6;
}
