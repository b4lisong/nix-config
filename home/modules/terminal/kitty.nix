/*
Kitty Terminal Configuration Module

This module replicates the multi-file structure from dotfiles/kitty/.config/kitty
to maintain cross-platform compatibility. Instead of using Home Manager's built-in
kitty options, we manually create the config files to match the original structure.
*/
{
  config,
  lib,
  pkgs,
  ...
}: let
  vars = import ../../../variables;
in {
  config = lib.mkIf (vars.preferences.terminal == "kitty") {
    home = {
      packages = with pkgs; [
        kitty # Install kitty terminal emulator
      ];

      # Create all kitty configuration files
      file = {
        # Create the main kitty.conf file that includes all config.d files
        ".config/kitty/kitty.conf".text = ''
          # Author:       Arszilla
          # Github:       https://github.com/Arszilla
          # Gitlab:       https://gitlab.com/Arszilla
          # Twitter:      https://twitter.com/Arszilla
          #
          # License:      MIT License
          # License URL:  https://gitlab.com/Arszilla/i3-dotfiles/-/blob/main/LICENSE
          #
          # kitty config
          # kitty Version: 0.26.5

          include ~/.config/kitty/config.d/appearance.conf
          include ~/.config/kitty/config.d/cursor.conf
          include ~/.config/kitty/config.d/keybinds.conf
          include ~/.config/kitty/config.d/tabs.conf
          include ~/.config/kitty/config.d/windows.conf

          scrollback_lines 99999

          enable_audio_bell yes
        '';

        # Appearance configuration (fonts, colors, theme)
        ".config/kitty/config.d/appearance.conf".text = ''
          # Author:       Arszilla
          # Github:       https://github.com/Arszilla
          # Gitlab:       https://gitlab.com/Arszilla
          # Twitter:      https://twitter.com/Arszilla
          #
          # License:      MIT License
          # License URL:  https://gitlab.com/Arszilla/i3-dotfiles/-/blob/main/LICENSE
          #
          # kitty config
          # kitty Version: 0.26.5

          # Fonts
          font_family      SauceCodePro Nerd Font Mono
          bold_font        SauceCodePro Nerd Font Mono
          italic_font      SauceCodePro Nerd Font Mono
          bold_italic_font SauceCodePro Nerd Font Mono

          font_size 10.0

          # Colors & Styling

          url_style straight

          active_tab_font_style   bold-italic
          inactive_tab_font_style italic

          window_border_width 1

          background_opacity 1.0

          background_image none

          dynamic_background_opacity no

          background_tint 0.0

          dim_opacity 1.0

          selection_foreground none
          selection_background none

          ## name:     Catppuccin Kitty Mocha
          ## author:   Catppuccin Org
          ## license:  MIT
          ## upstream: https://github.com/catppuccin/kitty/blob/main/themes/mocha.conf
          ## blurb:    Soothing pastel theme for the high-spirited!



          # The basic colors
          foreground              #cdd6f4
          background              #1e1e2e
          selection_foreground    #1e1e2e
          selection_background    #f5e0dc

          # Cursor colors
          cursor                  #f5e0dc
          cursor_text_color       #1e1e2e

          # URL underline color when hovering with mouse
          url_color               #f5e0dc

          # Kitty window border colors
          active_border_color     #b4befe
          inactive_border_color   #6c7086
          bell_border_color       #f9e2af

          # OS Window titlebar colors
          wayland_titlebar_color system
          macos_titlebar_color system

          # Tab bar colors
          active_tab_foreground   #11111b
          active_tab_background   #cba6f7
          inactive_tab_foreground #cdd6f4
          inactive_tab_background #181825
          tab_bar_background      #11111b

          # Colors for marks (marked text in the terminal)
          mark1_foreground #1e1e2e
          mark1_background #b4befe
          mark2_foreground #1e1e2e
          mark2_background #cba6f7
          mark3_foreground #1e1e2e
          mark3_background #74c7ec

          # The 16 terminal colors

          # black
          color0 #45475a
          color8 #585b70

          # red
          color1 #f38ba8
          color9 #f38ba8

          # green
          color2  #a6e3a1
          color10 #a6e3a1

          # yellow
          color3  #f9e2af
          color11 #f9e2af

          # blue
          color4  #89b4fa
          color12 #89b4fa

          # magenta
          color5  #f5c2e7
          color13 #f5c2e7

          # cyan
          color6  #94e2d5
          color14 #94e2d5

          # white
          color7  #bac2de
          color15 #a6adc8
        '';

        # Cursor configuration
        ".config/kitty/config.d/cursor.conf".text = ''
          # Author:       Arszilla
          # Github:       https://github.com/Arszilla
          # Gitlab:       https://gitlab.com/Arszilla
          # Twitter:      https://twitter.com/Arszilla
          #
          # License:      MIT License
          # License URL:  https://gitlab.com/Arszilla/i3-dotfiles/-/blob/main/LICENSE
          #
          # kitty config
          # kitty Version: 0.26.5

          shell_integration no-cursor

          cursor_shape block
          cursor_beam_thickness 15
          cursor_underline_thickness 2.0
          cursor_blink_interval 0.75
          cursor_stop_blinking_after 15.0
        '';

        # Keyboard shortcuts and mappings
        ".config/kitty/config.d/keybinds.conf".text = ''
          # Author:       Arszilla
          # Github:       https://github.com/Arszilla
          # Gitlab:       https://gitlab.com/Arszilla
          # Twitter:      https://twitter.com/Arszilla
          #
          # License:      MIT License
          # License URL:  https://gitlab.com/Arszilla/i3-dotfiles/-/blob/main/LICENSE
          #
          # kitty config
          # kitty Version: 0.26.5

          # Special Modifier
          kitty_mod ctrl+shift

          # General
          map kitty_mod+h         show_scrollback
          map kitty_mod+home      scroll_home
          map kitty_mod+end       scroll_end
          map kitty_mod+page_up   scroll_page_up
          map kitty_mod+page_down scroll_page_down
          map kitty_mod+up        scroll_line_up
          map kitty_mod+down      scroll_line_down
          map kitty_mod+k         scroll_line_up
          map kitty_mod+j         scroll_line_down
          map kitty_mod+x         scroll_to_prompt 1
          map kitty_mod+z         scroll_to_prompt -1

          # Window Management
          map kitty_mod+enter     new_window
          map kitty_mod+w         close_window
          map kitty_mod+l         next_layout
          map kitty_mod+]         next_window
          map kitty_mod+[         previous_window
          map kitty_mod+f         move_window_forward
          map kitty_mod+b         move_window_backward
          map kitty_mod+`         move_window_to_top
          map kitty_mod+1         first_window
          map kitty_mod+2         second_window
          map kitty_mod+3         third_window
          map kitty_mod+4         fourth_window
          map kitty_mod+5         fifth_window
          map kitty_mod+6         sixth_window
          map kitty_mod+7         seventh_window
          map kitty_mod+8         eighth_window
          map kitty_mod+9         ninth_window
          map kitty_mod+0         tenth_window

          # Tab Management
          map kitty_mod+t         new_tab
          map kitty_mod+q         close_tab
          map kitty_mod+left      previous_tab
          map kitty_mod+right     next_tab
          map kitty_mod+.         move_tab_forward
          map kitty_mod+,         move_tab_backward
          map kitty_mod+alt+t     set_tab_title

          # Miscellaneous
          map ctrl+plus           increase_font_size
          map ctrl+minus          decrease_font_size
          map ctrl+equal          restore_font_size
        '';

        # Tab bar configuration
        ".config/kitty/config.d/tabs.conf".text = ''
          # Author:       Arszilla
          # Github:       https://github.com/Arszilla
          # Gitlab:       https://gitlab.com/Arszilla
          # Twitter:      https://twitter.com/Arszilla
          #
          # License:      MIT License
          # License URL:  https://gitlab.com/Arszilla/i3-dotfiles/-/blob/main/LICENSE
          #
          # kitty config
          # kitty Version: 0.26.5

          tab_bar_edge bottom
          tab_bar_margin_width 20.0
          tab_bar_margin_height 20.0 0.0
          tab_bar_style powerline
          tab_bar_align left
          tab_bar_min_tabs 2
          tab_switch_strategy previous

          tab_powerline_style slanted

          tab_activity_symbol none

          tab_title_template "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title}"

          active_tab_title_template none
        '';

        # Window management configuration
        ".config/kitty/config.d/windows.conf".text = ''
          # Author:       Arszilla
          # Github:       https://github.com/Arszilla
          # Gitlab:       https://gitlab.com/Arszilla
          # Twitter:      https://twitter.com/Arszilla
          #
          # License:      MIT License
          # License URL:  https://gitlab.com/Arszilla/i3-dotfiles/-/blob/main/LICENSE
          #
          # kitty config
          # kitty Version: 0.26.5

          window_margin_width 0
          window_padding_width 20

          remember_window_size yes

          placement_strategy center

          confirm_os_window_close -1
        '';

        # Mouse configuration (not included in main kitty.conf but creating for completeness)
        ".config/kitty/config.d/mouse.conf".text = ''
          # Author:       Arszilla
          # Github:       https://github.com/Arszilla
          # Gitlab:       https://gitlab.com/Arszilla
          # Twitter:      https://twitter.com/Arszilla
          #
          # License:      MIT License
          # License URL:  https://gitlab.com/Arszilla/i3-dotfiles/-/blob/main/LICENSE
          #
          # kitty config
          # kitty Version: 0.26.5

          mouse_hide_wait 3.0
          click_interval 1.0
        '';
      };
    };
  };
}
