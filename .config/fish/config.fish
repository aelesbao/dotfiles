fish_config theme choose "tokyonight_night"

if status is-interactive
  # Commands to run in interactive sessions can go here
  if type -q brew
    set -gx HOMEBREW_NO_ENV_HINTS 1
    set -gx HOMEBREW_NO_AUTO_UPDATE 1

    eval (brew shellenv)
  end

  # Getting rid of "last login" message and fish's greeting
  touch ~/.hushlogin

  # Increase fish escape delay for ESC+q
  set -U fish_escape_delay_ms 300

  direnv hook fish | source
  starship init fish | source
  zoxide init fish | source
end

alias resource "source ~/.config/fish/config.fish"

alias ls    eza
alias la    "ls -lha"
alias tree  "eza --tree"
alias cat   "bat --decorations=never --paging=never"
alias diff  delta
alias du    dust

abbr --global rm    trash
abbr --global rmrf  /bin/rm -rf

abbr --global gws   git status
abbr --global gwd   git diff --no-ext-diff
abbr --global gs    git stash
abbr --global gr    git rebase
abbr --global gri   git rebase --interactive
abbr --global lz    lazygit
abbr --global y     yadm

abbr --global k     kubectl
abbr --global dk    docker
abbr --global dc    docker compose

abbr --global vi    nvim
abbr --global vim   nvim

abbr --global yz    yazi

abbr --global cc    claude
abbr --global cx    codex
abbr --global oc    opencode


function backup
  rsync -Phamuzv \
    --exclude "*~" \
    --exclude "*.swp" \
    --exclude "*.DS_Store*" \
    --exclude ".Spotlight-V100" \
    --exclude ".Trashes" \
    --exclude "ehthumbs.db" \
    --exclude "Thumbs.db" \
    --exclude "lost+found" \
    $argv
end

# bun
set -gx BUN_INSTALL "$HOME/.bun"
set --export PATH "$HOME/.local/bin" $PATH
