#!/bin/bash

font="-*-nu-*-*-*-*-11-*-*-*-*-*-*-*"
term=urxvtc
normbgcolor="#303030"
normfgcolor="#FFFFFF"
selbgcolor="#3465A4"
selfgcolor="#FFFFFF"

cmd=$(dmenu_path | dmenu -i -b -fn $font -nb $normbgcolor -nf $normfgcolor -sb $selbgcolor -sf $selfgcolor)

case ${basecmd} in
  ncmpcpp|htop|vim)   exec $term -name $cmd -e $cmd ;;
  tmux)               exec $term -name tmux -geometry 122x77 -e tmux -L main attach ;;
  *)                  exec $cmd
esac
