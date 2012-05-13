#!/usr/bin/env python3

import argparse, os, glob, sys, operator, fnmatch

def pathwalk(path, filter, order, recurse=False):
    """walk along a path and stat the matching files"""
    entries = dict()

    for root, dirs, files in os.walk(path):
        for f in files:
            if filter and not fnmatch.fnmatch(f, filter):
                continue

            fullpath = os.path.join(root, f)
            entries[fullpath] = os.lstat(fullpath).st_mtime

        if not recurse: break

    return sorted(entries.items(), key=operator.itemgetter(1), reverse=order)

def print_each(*args):
    """print a filename plus the delimiter"""
    sys.stdout.write("%s%c" % args)
    return 0

def unlink_each(*args):
    """attempt to unlink a file"""
    try:
        os.unlink(args[0])
        return 0
    except OSError(errno, strerror):
        sys.stderr.write("%s: cannot unlink `%s': %s\n" % (sys.argv[0], args[0], strerror))
        return 1

def main():
    parser = argparse.ArgumentParser(description='find the latest files in a directory',
            epilog='path defaults to the current directory if unspecified')

    parser.add_argument('-0', '--null', action='store_const', dest='delim', default='\n',
            const='\0', help='null delimit output')

    parser.add_argument('-r', '--recurse', action='store_true', dest='recurse', default=False,
            help='recurse into directories')

    parser.add_argument('-i', '--inverse', action='store_true', dest='inverse', default=False,
            help='invert selection (all except latest count)')

    parser.add_argument('-d', '--delete', action='store_const', dest='action', default=print_each,
            const=unlink_each, help='delete each candidate instead')

    parser.add_argument('-n', '--count', action='store', dest='count', default=1, type=int,
            metavar='N', help='number of files to select')

    parser.add_argument('-o', '--oldest', action='store_true', dest='reverse', default=False,
            help='examine oldest files')

    parser.add_argument('-f', '--filter', action='store', dest='filter', default=None,
            metavar='PAT', help='filter files on glob pattern')

    parser.add_argument('path', default='.', nargs='?', help='path to search')

    opts = parser.parse_args()

    if not os.path.exists(opts.path):
        sys.stderr.write("error: path not found: %s\n" % opts.path)
        sys.exit(os.EX_OSFILE)

    files = pathwalk(opts.path, opts.filter, opts.reverse, opts.recurse)
    if not files:
        sys.exit(os.EX_DATAERR)

    if opts.inverse:
        candidates = files[0:len(files) - opts.count]
    else:
        candidates = files[-(opts.count):]

    error = 0
    for cand in candidates:
        error += opts.action(cand[0], opts.delim)

    sys.exit(bool(error))

main()
