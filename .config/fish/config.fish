set -gx fish_greeting
set -gx ANSIBLE_FORCE_COLOR true
set -gx EDITOR nvim

fish_config theme choose "Catppuccin Mocha"

if status is-interactive
    eval (brew shellenv)
end

direnv hook fish | source
starship init fish | source
zoxide init fish | source

abbr --global k kubectl
abbr --global vim nvim
abbr --global vi nvim
abbr --global ls l
