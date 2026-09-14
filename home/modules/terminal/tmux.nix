/*
`home/modules/terminal/tmux.nix`
Baseline tmux configuration using Home Manager's built-in programs.tmux module.

Settings here are tuned for running terminal agents such as Claude Code inside
tmux, both locally and over SSH. The agent TUI is an alternate-screen
application that relies on extended key encoding, OSC passthrough and a
truecolor-capable TERM, none of which tmux forwards under its defaults.
*/
{...}: {
  programs.tmux = {
    enable = true;

    # Home Manager defaults this to "screen", which would downgrade the
    # tmux-256color TERM tmux 3.6 already selects and break color and key
    # reporting in TUI applications.
    terminal = "tmux-256color";

    # Agent transcripts are long; the 2000-line default loses most of a session.
    historyLimit = 50000;

    # Escape is the interrupt key in Claude Code. A larger delay makes tmux
    # wait to disambiguate it from an escape sequence, which reads as a hang.
    escapeTime = 10;

    # Let applications know when their pane gains or loses focus.
    focusEvents = true;

    # The wheel still reaches alternate-screen applications untouched; this
    # only adds scrollback and pane-aware selection at the shell prompt.
    mouse = true;

    extraConfig = ''
      # Shift+Enter and Option+Enter insert newlines in the agent prompt. Both
      # are CSI u sequences that tmux drops unless extended keys are forwarded
      # and the outer terminal is known to accept them.
      set -s extended-keys always
      set -as terminal-features '*:extkeys'

      # Truecolor for the agent TUI. Supersedes the legacy terminal-overrides
      # Tc capability on tmux 3.2 and later.
      set -as terminal-features '*:RGB'

      # Let OSC sequences reach the outer terminal instead of being consumed by
      # tmux, so inline images and progress reporting survive the multiplexer.
      set -g allow-passthrough on

      # OSC 52. Over SSH this is the only path by which a selection made in a
      # remote tmux reaches the local system clipboard.
      set -g set-clipboard on

      # The agent rings the bell when it needs input. Surface that from
      # background windows rather than swallowing it or blocking on a message.
      setw -g monitor-bell on
      set -g bell-action other
      set -g visual-bell off
      set -g set-titles on
    '';
  };
}
