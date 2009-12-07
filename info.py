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
blank = [ '', '', '', '', '', '', '', '', '' ] 

# Find running processes
p1 = Popen(['ps', '-A'], stdout=PIPE)
p2 = Popen(["awk", '{print $4}'], stdin=p1.stdout, stdout=PIPE)
processes = p2.communicate()[0].split("\n")
p1 = p2 = None

# Print coloured key with normal value.
def output(key, value):
	output = "%s%s:%s %s" % (color, key, clear, value)
	list.append(output)

def os_display(): 
	os = "Arch Linux"	
	output('OS', os)

def kernel_display():
	kernel = Popen(["uname", "-r"], stdout=PIPE).communicate()[0].rstrip("\n")
	output ('Kernel', kernel)

def uptime_display():
	p1 = Popen(["uptime"], stdout=PIPE)
	p2 = Popen(['sed', '-e', 's/^.*up //', "-e", 's/, *[0-9]*.users.*//'], stdin=p1.stdout, stdout=PIPE)
	uptime = p2.communicate()[0].rstrip("\n")
	output ('Uptime', uptime)
	p1 = p2 = None

def battery_display(): 
	p1 = Popen(["acpi"], stdout=PIPE)
	p2 = Popen(["sed", 's/.*, //'], stdin=p1.stdout, stdout=PIPE)
	battery = p2.communicate()[0].rstrip("\n")
	output ('Battery', battery)
	p1 = p2 = None

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

def packages_display():
	p1 = Popen(["pacman", "-Q"], stdout=PIPE)
	p2 = Popen(["wc", "-l"], stdin=p1.stdout, stdout=PIPE)
	packages = p2.communicate()[0].rstrip("\n")
	output ('Packages', packages)

def fs_display():
	p1 = Popen(["df", "-Th"], stdout=PIPE)
	p2 = Popen(["grep", "/$"], stdin=p1.stdout, stdout=PIPE)
	p3 = Popen(["awk", '{print $4}'], stdin=p2.stdout, stdout=PIPE)
	root = p3.communicate()[0].rstrip("\n")
	output ('Root', root)
	p1 = p2 = p3 = None


# Values to display.	
# Possible options: os, kernel, uptime, battery, de, wm, packages, fs.
display = [ 'os', 'kernel', 'uptime', 'de', 'wm', 'packages', 'fs' ]

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
%s    .#######;     ;#####.       %s
%s    #########.   .########`     %s
%s   ######'           '######    %s
%s  ;####                 ####;   
%s  ##'                     '##   
%s #'                         `#  %s                          
""" % (color, color, color, color, list[0], color, list[1], color, list[2], color, list[3], color, list[4], color, list[5], color, color2, color, list[6], color, color2, color, list[7], color, color2, list[8], color2, list[9], color2, list[10], color2, list[10], color2, list[10], color2, color2, color2, clear)
