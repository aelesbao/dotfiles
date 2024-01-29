# vim:fileencoding=utf-8:ft=tmux:foldmethod=marker

# Assigns custom user keys
run -b '~/.config/tmux/user-keys.sh'

# too lazy to hold shift
bind ';' command-prompt

# Improved copy mode
# set vi-mode
set-window-option -g mode-keys vi
# keybindings
bind -T copy-mode-vi v   send-keys -X begin-selection
bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind -T copy-mode-vi y   send-keys -X copy-selection

# Pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Pane resizing
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Zoom in and out
bind -n User0 resize-pane -Z

# Resize based on percentage
bind User12 resize-pane -x '50%'
bind User13 resize-pane -x '66%'
bind User14 resize-pane -x '75%'
bind User22 resize-pane -y '50%'
bind User23 resize-pane -y '66%'
bind User24 resize-pane -y '75%'

# Pane split bindings
bind '|' split-window -fh -c "#{pane_current_path}"
bind '\' split-window -h -c "#{pane_current_path}"
bind '-' split-window -v -c "#{pane_current_path}"
bind '_' split-window -fv -c "#{pane_current_path}"
bind '%' split-window -h -c "#{pane_current_path}"
bind '"' split-window -v -c "#{pane_current_path}"

# Smart pane switching with awareness of Vim splits.
# See: https://github.com/christoomey/vim-tmux-navigator
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | \
   grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf|lazygit)(diff)?$'"

bind -n 'M-h' if-shell "$is_vim" 'send-keys M-h' 'select-pane -L'
bind -n 'M-j' if-shell "$is_vim" 'send-keys M-j' 'select-pane -D'
bind -n 'M-k' if-shell "$is_vim" 'send-keys M-k' 'select-pane -U'
bind -n 'M-l' if-shell "$is_vim" 'send-keys M-l' 'select-pane -R'

# Select the last pane keeping the zoom status
bind -n 'M-;' select-pane -Z -t :.+

bind -T copy-mode-vi 'M-h' select-pane -L
bind -T copy-mode-vi 'M-j' select-pane -D
bind -T copy-mode-vi 'M-k' select-pane -U
bind -T copy-mode-vi 'M-l' select-pane -R
bind -T copy-mode-vi 'M-;' select-pane -l

# Window navigation
bind -n 'M-{' previous-window
bind -n 'M-}' next-window

# Switch windows alt+number
bind -n M-1 select-window -t 1
bind -n M-2 select-window -t 2
bind -n M-3 select-window -t 3
bind -n M-4 select-window -t 4
bind -n M-5 select-window -t 5
bind -n M-6 select-window -t 6
bind -n M-7 select-window -t 7
bind -n M-8 select-window -t 8
bind -n M-9 select-window -t 9

# Window swapping
bind -r "<" swap-window -d -t -1
bind -r ">" swap-window -d -t +1

# Open new window
bind -n M-t new-window
bind c new-window -c "#{pane_current_path}"

# Clears the terminal history
bind -n C-l send C-l \; clear-history

# Open tmux config in an editor
bind -n 'M-,' run 'tmux new-window -n tmux -S -c ~/.config/tmux "nvim -O options.tmux keymaps.tmux plugins.tmux"'
