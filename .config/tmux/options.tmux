# vim:fileencoding=utf-8:ft=tmux:foldmethod=marker

# Change tmux prefix key to Ctrl+S because it's easier to hit
set-option -g prefix C-s

# Avoid that tmux starts a login shell by default
set-option -g default-command "${SHELL}"

# Enables extended terminal capabilities in tmux
# set-option -s default-terminal 'xterm-kitty'

set-option -s editor 'nvim'

# Instructs the session to use True Color (24 bit) if the terminal supports it
set-option -sa terminal-overrides ',*256color*:Tc'
set-option -sa terminal-overrides ',alacritty*:Tc'
set-option -sa terminal-overrides ',*kitty:Tc'

# Enable hyperlinks (tmux 3.4 and above)
set -ga terminal-features '*:hyperlinks'

# Enables undercurl in Alacritty
set-option -sa terminal-features ',alacritty*:usstyle'

# Undercurl support
set -sa terminal-overrides ',*:Smulx=\E[4::%p1%dm'  
# Underscore colors
set -sa terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

# Set the clipboard to on to both make tmux set the clipboard for the outside terminal,
# and allows applications inside tmux to set tmux's clipboard (adding a paste buffer).
set -s set-clipboard on

# Enable mouse mode (tmux 2.1 and above)
set-option -g mouse on

# Start windows and panes at 1, not 0
set-option -g base-index 1
set-option -g pane-base-index 1
set-window-option -g pane-base-index 1

# When we add/remove windows, renumber them in sequential order.
set-option -g renumber-windows on

# Allow programs in the pane to change the window name using a terminal escape sequence
# set-option allow-rename on
# Rename windows using the git root directory (wip)
set-option -g automatic-rename off
# set-option -g automatic-rename-format '#{b:pane_current_path}#{?pane_in_mode,[#{pane_current_command}],}'

# Move the status bar to the top
set-option -g status-position bottom

# Enable visual alerts for windows. Hide bells/silence.
set-window-option -g monitor-activity off # highlight active windows?
set-option -g visual-activity off         # show a message on window activity?
set-option -g visual-silence on
set-option -g visual-bell off
set-option -g bell-action none

# Constrain the window only if a smaller client is actively looking at it.
set-option -g window-size latest
set-window-option -g aggressive-resize on

# Goes to the previous session if the current one is destroyed
set-option -g detach-on-destroy off

# Improves the Ctrl+L history cleaning
set-option -g scroll-on-clear off

# Improved copy mode
# set vi-mode
set-window-option -g mode-keys vi
