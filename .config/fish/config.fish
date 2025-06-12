set -gx fish_greeting
set -gx ANSIBLE_FORCE_COLOR true
set -gx EDITOR nvim

fish_config theme choose "tokyonight_night"

if status is-interactive
    if type -q brew
        eval (brew shellenv)
    end

    direnv hook fish | source
    starship init fish | source
    zoxide init fish | source
end

abbr --global k kubectl
abbr --global vim nvim
abbr --global vi nvim
abbr --global ls l
