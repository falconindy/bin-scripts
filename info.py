#!/usr/bin/env python

from subprocess import Popen, PIPE

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

# Find running processes
p1 = Popen(['ps', '-A'], stdout=PIPE).communicate()[0].split('\n')
processes = [process.split()[3] for process in p1 if process]
p1 = None

# Print coloured key with normal value.
def output(key, value):
    output = "%s%s:%s %s" % (color, key, clear, value)
    list.append(output)

def os_display():
    arch = Popen(['uname', '-m'], stdout=PIPE).communicate()[0].rstrip('\n')
    os = "Arch Linux %s" % arch
    output('OS', os)

def kernel_display():
    kernel = Popen(['uname', '-r'], stdout=PIPE).communicate()[0].rstrip("\n")
    output('Kernel', kernel)

def uptime_display():
    fuptime = int(open('/proc/uptime').read().split(' ')[0].split('.')[0])
    day = int(fuptime / 86400)
    fuptime = fuptime % 86400
    hour = int(fuptime / 3600)
    fuptime = fuptime % 3600
    minute = int(fuptime / 60)
    uptime = ''
    if day > 0:
        uptime += '%d days, ' % day
    uptime += '%d:%2d' % (hour, minute)
    output('Uptime', uptime)
 
def battery_display():
    p1 = Popen(['acpi'], stdout=PIPE).communicate()[0].split(,)
    battery = p1[1]
    output('Battery', battery)

def de_display():
    dict = {'gnome-session': 'GNOME',
        'ksmserver': 'KDE',
        'xfce-mcs-manager': 'Xfce'}
    de = 'None found'
    for key in dict.keys():
        if key in processes: de = dict[key]
    output('DE', de)

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
    output('WM', wm)

def packages_display():
    packages = len(Popen(['pacman', '-Q'], stdout=PIPE).communicate()[0].split('\n')) - 1
    output('Packages', packages)

def fs_display(mount='/'):
    p1 = Popen(['df', '-h', mount], stdout=PIPE).communicate()[0]
    part = [line for line in p1.split('\n') if line][1].split()[1].rpartition('/')[2]
    if len(mount) == 1:
        fs = 'Root'
    else:
        fs = mount.rpartition('/')[2].title()
    output(fs, part)

def blank_display():
    list.append('')

# Values to display:
# Possible options: os, kernel, uptime, battery, de, wm, packages, fs, blank
display = ['os', 'kernel', 'uptime', 'wm', 'packages', 'blank', 'fs=/', 'fs=/usr', 'fs=/home', 'fs=/mnt/Destruction', 'fs=/mnt/Entropy', 'fs=/mnt/Gluttony']

for x in display:
    call = [arg for arg in x.split('=') if arg]
    funcname=call[0] + "_display"
    func=locals()[funcname]
    if len(call) > 1:
        func(call[1])
    else:
        func()

list.extend([' ']*(13 - len(display)))

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
%s    .#######;     ;#####.       %s
%s    #########.   .########`     %s
%s   ######'           '######    %s
%s  ;####                 ####;
%s  ##'                     '##
%s #'                         `#  %s
""" % (color, color, color, color, list[0], color, list[1], color, list[2], color, list[3], color, list[4], color, list[5], color, color2, color, list[6], color, color2, color, list[7], color, color2, list[8], color2, list[9], color2, list[10], color2, list[11], color2, list[12], color2, color2, color2, clear)

