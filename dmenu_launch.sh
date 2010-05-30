#!/bin/bash
font="-*-nu-*-*-*-*-11-*-*-*-*-*-*-*"
normbgcolor="#303030"
normfgcolor="#FFFFFF"
selbgcolor="#3465A4"
selfgcolor="#FFFFFF"

dmenu_run -i -b -fn $font -nb $normbgcolor -nf $normfgcolor -sb $selbgcolor -sf $selfgcolor
