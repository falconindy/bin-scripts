#!/usr/bin/env python

import os, sys, argparse
from subprocess import PIPE, Popen

CACHEFILE = os.path.join(os.getenv('HOME'), '.cache/solinks')

SEARCHPATHS = [
    '/lib/',
    '/lib32/',
    '/usr/lib/',
    '/usr/lib32/',
    '/usr/local/lib/',
    '/usr/local/lib32/',
    '/bin/',
    '/sbin/',
    '/usr/bin/',
    '/usr/sbin/'
    '/opt/',
]

def stdout_of(cmd):
    return Popen(cmd,
            stdout=PIPE,
            stderr=PIPE).communicate()[0].decode('utf-8')

def has_prefix(i):
    for path in SEARCHPATHS:
        if i.startswith(path):
            return True

    return False

def write_solinks(cachefile, pkg, files):
    out = stdout_of(['objdump', '-p'] + files)

    links = []

    for line in out.split('\n'):
        try:
            section, solink = line.strip().split(' ', 1)
        except:
            continue

        if section == "NEEDED":
            links.append(solink.strip())

    for link in sorted(set(links)):
        print("{}\t{}".format(pkg, link), file=cachefile)

def sogrep(search):
    with open(CACHEFILE) as solinks:
        for line in solinks:
            pkgname, soname = line.rstrip().split('\t')
            if soname.startswith(search):
                print(pkgname)

def createlinks():
    pkgs = {}
    filelist = stdout_of(['pacman', '-Ql'])

    for f in filelist.split('\n'):
        if not f:
            break
        pkg, fname = f.split(' ', 1)

        if fname.endswith('/') or not has_prefix(fname) or os.path.islink(fname):
            continue

        if not pkgs.get(pkg):
            pkgs[pkg] = []
        pkgs[pkg].append(fname)

    with open(CACHEFILE, "w") as cachefile:
        for k, v in sorted(pkgs.items()):
            write_solinks(cachefile, k, v)

def main():
    parser = argparse.ArgumentParser(description='find soname revdeps')

    parser.add_argument('-c', '--create', action='store_true', dest='create', default=False,
            help='rebuild soname cache')

    parser.add_argument('soname', nargs='?', help='soname to search')

    opts = parser.parse_args()

    if opts.create:
        createlinks()
    else:
        if not opts.soname:
            print("error: no soname specified", file=sys.stderr)
            sys.exit(1)
        sogrep(opts.soname)

if __name__ == '__main__':
    main()

