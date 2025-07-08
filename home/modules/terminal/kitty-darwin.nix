/*
Darwin-specific Kitty Terminal Overrides

This module provides macOS-specific enhancements and optimizations for kitty
using Home Manager's built-in programs.kitty module. It adds Darwin-specific
settings and keybindings on top of the cross-platform baseline.
*/
{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (pkgs.stdenv.isDarwin && config.programs.kitty.enable) {
    programs.kitty = {
      # Darwin-specific font size (larger for high-DPI displays)
      font.size = lib.mkForce 14;

      # Darwin-specific settings overrides
      settings = {
        # Enhanced padding for macOS aesthetic
        window_padding_width = lib.mkForce 25;

        # Modern translucent look
        background_opacity = lib.mkForce "0.95";

        # macOS-specific window behavior
        macos_titlebar_color = "system";
        macos_option_as_alt = true;
        macos_hide_from_tasks = false;
        macos_quit_when_last_window_closed = true;

        # Hide title bar for cleaner look on macOS
        hide_window_decorations = "titlebar-only";

        # Performance optimizations for macOS
        repaint_delay = 10;
        input_delay = 3;
        sync_to_monitor = true;

        # Window behavior
        initial_window_width = 1200;
        initial_window_height = 800;

        # Bell configuration for macOS
        visual_bell_duration = "0.0";
        window_alert_on_bell = true;
        bell_on_tab = "🔔 ";
      };

      # Darwin-specific keybindings (native macOS shortcuts)
      keybindings = {
        # Native macOS clipboard shortcuts
        "cmd+c" = "copy_to_clipboard";
        "cmd+v" = "paste_from_clipboard";

        # Native macOS tab management
        "cmd+t" = "new_tab";
        "cmd+w" = "close_tab";
        "cmd+n" = "new_os_window";
        "cmd+shift+w" = "close_os_window";

        # Window management
        "cmd+enter" = "new_window";
        "cmd+d" = "close_window";
        # Split windows (macOS style)
        "cmd+shift+d" = "new_window_with_cwd";
        # Move the active window in the indicated direction (vi-style)
        "cmd+shift+k" = "move_window up";
        "cmd+shift+j" = "move_window down";
        "cmd+shift+h" = "move_window left";
        "cmd+shift+l" = "move_window right";

        # Tab navigation
        "cmd+shift+]" = "next_tab";
        "cmd+shift+[" = "previous_tab";
        "cmd+1" = "goto_tab 1";
        "cmd+2" = "goto_tab 2";
        "cmd+3" = "goto_tab 3";
        "cmd+4" = "goto_tab 4";
        "cmd+5" = "goto_tab 5";
        "cmd+6" = "goto_tab 6";
        "cmd+7" = "goto_tab 7";
        "cmd+8" = "goto_tab 8";
        "cmd+9" = "goto_tab 9";

        # Font size adjustment
        "cmd+plus" = "increase_font_size";
        "cmd+minus" = "decrease_font_size";
        "cmd+0" = "restore_font_size";

        # Scrolling
        "cmd+k" = "scroll_line_up";
        "cmd+j" = "scroll_line_down";
        "cmd+home" = "scroll_home";
        "cmd+end" = "scroll_end";

        # Search
        "cmd+f" = "show_scrollback";
      };
    };
  };
}
