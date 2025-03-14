{
  pkgs,
  config,
  ...
}: {
  # i3 config inspired by ryan4yin &
  # https://github.com/endeavouros-team/endeavouros-i3wm-setup

  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # wallpaper, binary file
  #home.file.".config/i3/wallpaper.jpg".source = ../../wallpaper.jpg;

  home.file.".config/i3/config".source = ./config;
  home.file.".config/i3/i3blocks.conf".source = ./i3blocks.conf;
  home.file.".config/i3/keybindings".source = ./keybindings;
  home.file.".config/i3/scripts" = {
    source = ./scripts;
    # copy the scripts directory recursively
    recursive = true;
    executable = true; # make all scripts executable
  };
}
