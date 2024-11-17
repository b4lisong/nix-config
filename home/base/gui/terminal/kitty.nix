{
  lib,
  pkgs,
  ...
}: {
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    theme = "Catppuccin-Mocha";
    font = {
      name = "JetBrainsMono Nerd Font";
      # use different font size on macOS
      size =
        if pkgs.stdenv.isDarwin
        then 14
        else 13;
    };
    keybindings = {
      "f1" = "show_kitty_env_vars";
      "ctrl+shift+m" = "toggle_maximized";
      "ctrl+shift+f" = "show_scrollback"; # search in the current window
    };
    settings = {
      background_opacity = "0.9";
      background_tint = "0.9";
      background_blur = 10;
      dim_opacity = "1.0";
      tab_bar_edge = "bottom";
      tab_bar_margin_width = "20.0";
      tab_bar_margin_height = "20.0 0.0";
      tab_bar_style = "powerline";
      tab_bar_align = "left";
      tab_bar_min_tabs = 2;
      tab_switch_strategy = "previous";
      tab_activity_symbol = "none";
      tab_powerline_style = "slanted";
      tab_title_template = "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title}";
      active_tab_title_template = "none";
      scrollback_lines = 10000;
      enable_audio_bell = false;
      window_margin_width = 0;
      window_padding_width = 20;
      remember_window_size = true;
      placement_strategy = "center";
      confirm_os_window_close = 0;
      hide_window_decorations = "titlebar-only";
      macos_quit_when_last_window_closed = true;
    };
    # macOS-specific
    darwinLaunchOptions = ["--single-instance"];
  };
}
