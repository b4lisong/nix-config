/*
Kitty Terminal Baseline Configuration

This module provides the baseline kitty configuration using Home Manager's
built-in programs.kitty module. It contains all cross-platform settings
from the original dotfiles configuration.
*/
{...}: {
  # Kitty terminal configuration using Home Manager's built-in module
  programs.kitty = {
    enable = true;

    # Font configuration
    font = {
      name = "SauceCodePro Nerd Font Mono";
      size = 10; # Baseline size, platform-specific modules can override
    };

    # Cross-platform settings (from your dotfiles)
    settings = {
      # Scrollback and audio
      scrollback_lines = 99999;
      enable_audio_bell = true;

      # Window settings
      window_margin_width = 0;
      window_padding_width = 20; # Baseline padding, platform-specific modules can override
      remember_window_size = true;
      placement_strategy = "center";
      confirm_os_window_close = -1;

      # Cursor settings
      shell_integration = "no-cursor";
      cursor_shape = "block";
      cursor_beam_thickness = 15;
      cursor_underline_thickness = "2.0";
      cursor_blink_interval = "0.75";
      cursor_stop_blinking_after = 15;

      # Tab bar settings
      tab_bar_edge = "bottom";
      tab_bar_margin_width = "20.0";
      tab_bar_margin_height = "20.0 0.0";
      tab_bar_style = "powerline";
      tab_bar_align = "left";
      tab_bar_min_tabs = 2;
      tab_switch_strategy = "previous";
      tab_powerline_style = "slanted";
      tab_activity_symbol = "none";
      tab_title_template = "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title}";
      active_tab_title_template = "none";

      # Mouse settings
      mouse_hide_wait = "3.0";
      click_interval = "1.0";

      # Appearance settings
      url_style = "straight";
      active_tab_font_style = "bold-italic";
      inactive_tab_font_style = "italic";
      window_border_width = 1;
      background_opacity = "1.0"; # Baseline opacity, platform-specific modules can override
      background_image = "none";
      dynamic_background_opacity = false;
      background_tint = "0.0";
      dim_opacity = "1.0";

      # Catppuccin Mocha theme colors
      foreground = "#cdd6f4";
      background = "#1e1e2e";
      selection_foreground = "#1e1e2e";
      selection_background = "#f5e0dc";
      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";
      url_color = "#f5e0dc";
      active_border_color = "#b4befe";
      inactive_border_color = "#6c7086";
      bell_border_color = "#f9e2af";
      wayland_titlebar_color = "system";
      macos_titlebar_color = "system";
      active_tab_foreground = "#11111b";
      active_tab_background = "#cba6f7";
      inactive_tab_foreground = "#cdd6f4";
      inactive_tab_background = "#181825";
      tab_bar_background = "#11111b";

      # Mark colors
      mark1_foreground = "#1e1e2e";
      mark1_background = "#b4befe";
      mark2_foreground = "#1e1e2e";
      mark2_background = "#cba6f7";
      mark3_foreground = "#1e1e2e";
      mark3_background = "#74c7ec";

      # Terminal colors
      color0 = "#45475a";
      color8 = "#585b70";
      color1 = "#f38ba8";
      color9 = "#f38ba8";
      color2 = "#a6e3a1";
      color10 = "#a6e3a1";
      color3 = "#f9e2af";
      color11 = "#f9e2af";
      color4 = "#89b4fa";
      color12 = "#89b4fa";
      color5 = "#f5c2e7";
      color13 = "#f5c2e7";
      color6 = "#94e2d5";
      color14 = "#94e2d5";
      color7 = "#bac2de";
      color15 = "#a6adc8";
    };

    # Key bindings (from your keybinds.conf)
    keybindings = {
      # General scrolling and navigation
      "ctrl+shift+h" = "show_scrollback";
      "ctrl+shift+home" = "scroll_home";
      "ctrl+shift+end" = "scroll_end";
      "ctrl+shift+page_up" = "scroll_page_up";
      "ctrl+shift+page_down" = "scroll_page_down";
      "ctrl+shift+up" = "scroll_line_up";
      "ctrl+shift+down" = "scroll_line_down";
      "ctrl+shift+k" = "scroll_line_up";
      "ctrl+shift+j" = "scroll_line_down";
      "ctrl+shift+x" = "scroll_to_prompt 1";
      "ctrl+shift+z" = "scroll_to_prompt -1";

      # Window management
      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+w" = "close_window";
      "ctrl+shift+l" = "next_layout";
      "ctrl+shift+]" = "next_window";
      "ctrl+shift+[" = "previous_window";
      "ctrl+shift+f" = "move_window_forward";
      "ctrl+shift+b" = "move_window_backward";
      "ctrl+shift+`" = "move_window_to_top";
      "ctrl+shift+1" = "first_window";
      "ctrl+shift+2" = "second_window";
      "ctrl+shift+3" = "third_window";
      "ctrl+shift+4" = "fourth_window";
      "ctrl+shift+5" = "fifth_window";
      "ctrl+shift+6" = "sixth_window";
      "ctrl+shift+7" = "seventh_window";
      "ctrl+shift+8" = "eighth_window";
      "ctrl+shift+9" = "ninth_window";
      "ctrl+shift+0" = "tenth_window";

      # Tab management
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+." = "move_tab_forward";
      "ctrl+shift+," = "move_tab_backward";
      "ctrl+shift+alt+t" = "set_tab_title";

      # Font size
      "ctrl+plus" = "increase_font_size";
      "ctrl+minus" = "decrease_font_size";
      "ctrl+equal" = "restore_font_size";
    };
  };
}
