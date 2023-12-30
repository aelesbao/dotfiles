#!/bin/sh

# Reserved code ranges
#
# 0-9   : general use
# 10-19 : ctrl+<number>
# 20-29 : ctrl+alt+<number>

# alt+shift+enter
tmux run -C 'set -s user-keys[0] "\e[10;13~"'

range=10
for csi in 5 7; do
  for k in $(seq 0 9); do
    tmux run -C 'set -s user-keys['$range'] "\e['$csi';'$((k+48))'~"'
    range=$((range+1))
  done
done
