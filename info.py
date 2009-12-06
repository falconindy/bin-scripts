#!/usr/bin/env python
# Credit to user 'melik' on archlinux.org forums

import commands

# Define colors
clear = "\x1b[0m"

# color = "\x1b[1;30m" # black
# color2 = "\x1b[0;30m" # black

# color = "\x1b[1;31m" # red 
# color2 = "\x1b[0;30m" # red

# color = "\x1b[1;32m" # green
# color2 = "\x1b[0;32m" # green

# color = "\x1b[1;33m" # yellow
# color2 = "\x1b[0;33m" # yellow

color = "\x1b[1;34m" # blue
color2 = "\x1b[0;34m" # blue

# color = "\x1b[1;35m" # magenta
# color2 = "\x1b[0;35m" # magenta

# color = "\x1b[1;36m" # cyan
# color2 = "\x1b[0;36m" # cyan

# color = "\x1b[1;37m" # white
# color2 = "\x1b[0;37m" # white

# Define arrays containing values.
list = []
blank = [ '', '', '', '', '', '', '', '', '' ] 

# Find running processes
processes = commands.getoutput("ps -A | awk {'print $4'}").split("\n")

# Print coloured key with normal value.
def output(key, value):
    output = "%s%s:%s %s" % (color, key, clear, value)
    list.append(output)

def distro_display(): 
    distro = "Arch Linux"    
    output('Distro', distro)

def kernel_display():
    kernel = commands.getoutput("uname -r")
    output ('Kernel', kernel)

def uptime_display():
    uptime = commands.getoutput('uptime | sed -e \'s/^.*up //\' -e \'s/, *[0-9]*.users.*//\'')
    output ('Uptime', uptime)

def battery_display(): 
    battery = commands.getoutput('acpi | sed \'s/.*, //\'')
    output ('Battery', battery)

def de_display():
    dict = {'gnome-session': 'GNOME',
        'ksmserver': 'KDE',
        'xfce-mcs-manager': 'Xfce'}
    de = 'None found'
    for key in dict.keys():
        if key in processes: de = dict[key]
    output ('DE', de)

def wm_display():
        dict = {'awesome': 'Awesome',
        'beryl': 'Beryl',
        'blackbox': 'Blackbox',
        'dwm': 'DWM',
        'enlightenment': 'Enlightenment',
                'fluxbox': 'Fluxbox',
        'fvwm': 'FVWM',
        'icewm': 'icewm',
        'kwin': 'kwin',
        'metacity': 'Metacity',
                'openbox': 'Openbox',
        'wmaker': 'Window Maker',
        'xfwm4': 'Xfwm',
        'xmonad': 'Xmonad'}  
        wm = 'None found'
        for key in dict.keys():
            if key in processes: wm = dict[key]
        output ('WM', wm)

# Values to display.    
# Possible options: kernel, uptime, battery, distro, de, wm, wmtheme, theme, font, icons.
display = [ 'distro', 'kernel', 'uptime', 'de', 'wm' ]

for x in display:
    funcname=x+"_display"
    func=locals()[funcname]
    func()

list.extend(blank)

# Result
print """%s
%s               +                
%s               #                
%s              ###               %s
%s             #####              %s
%s             ######             %s
%s            ; #####;            %s
%s           +##.#####            %s
%s          +##########           %s
%s         ######%s#####%s##;         %s
%s        ###%s############%s+        %s
%s       #%s######   #######        %s
%s     .######;     ;###;`\".      %s
%s    .#######;     ;#####.       
%s    #########.   .########`     
%s   ######'           '######    
%s  ;####                 ####;   
%s  ##'                     '##   
%s #'                         `#  %s                          
""" % (color, color, color, color, list[0], color, list[1], color, list[2], color, list[3], color, list[4], color, list[5], color, color2, color, list[6], color, color2, color, list[7], color, color2, list[8], color2, list[9], color2, color2, color2, color2, color2, color2, clear)
