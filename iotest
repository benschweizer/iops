#!/usr/bin/env python
#
# Copyright (c) 2008-2010 Benjamin Schweizer and others.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
#
# Abstract
# ~~~~~~~~
# Benchmark disk IOs
#
# Authors
# ~~~~~~~
# Benjamin Schweizer, http://benjamin-schweizer.de/contact
# Uwe Menges
#
# Changes
# ~~~~~~~
# 2010-07-22, benjamin: fixed 32bit ioctls on bsd
# 2010-07-21, benjamin: freebsd/osx support, switched to isc license
# 2009-09-16, uwe: changed formatting, fixed last block bug
# 2008-10-16, benjamin: initial release
#
# Todo
# ~~~~
# - add threading support to benchmark native command queueing
# - check/add netbsd/openbsd mediasize ioctls
#

import sys
import fcntl
import array
import struct
import random
import time

def mediasize(fh):
    """report the media size for an already open device"""

    if sys.platform in ['darwin']:
        # mac os x 10.5+ sysctl from sys/disk.h
        DKIOCGETBLOCKSIZE = 0x40046418
        DKIOCGETBLOCKCOUNT = 0x40086419

        buf = array.array('B', range(0,4))  # uint32
        r = fcntl.ioctl(fh.fileno(), DKIOCGETBLOCKSIZE, buf, 1)
        blocksize = struct.unpack('I', buf)[0]
        buf = array.array('B', range(0,8))  # uint64
        r = fcntl.ioctl(fh.fileno(), DKIOCGETBLOCKCOUNT, buf, 1)
        blockcount = struct.unpack('Q', buf)[0]

        mediasize = blocksize*blockcount
        return mediasize

    elif sys.platform in ['freebsd8']:
        # freebsd 8 sysctl from sys/disk.h
        DIOCGMEDIASIZE = 0x40086481

        buf = array.array('B', range(0,8))  # off_t / int64
        r = fcntl.ioctl(fh.fileno(), DIOCGMEDIASIZE, buf, 1)
        mediasize = struct.unpack('q', buf)[0]
        return mediasize

    else: # linux or compat
        # linux 2.6 lseek from fcntl.h
        SEEK_SET=0
        SEEK_CUR=1
        SEEK_END=2

        oldpos = fh.tell()
        fh.seek(0,SEEK_END)
        mediasize = fh.tell()
        fh.seek(oldpos, SEEK_SET)

    if not mediasize:
        raise Exception("cannot determine media size")

    return mediasize


def usage():
    print """Copyright (c) 2008-2010 Benjamin Schweizer and others.

usage:

    iotest <device> [time]

    device  := some block device
    time    := time in seconds

example:

    iotest /dev/sda

"""


def greek(value, precision = 0, prefix = ''):
    """Return a string representing the IEC or SI suffix of a value"""
    # Copyright (c) 1999 Martin Pohl, copied from
    # http://mail.python.org/pipermail/python-list/1999-December/018519.html
    if prefix != '':
        # Use SI (10-based) units
        _abbrevs = [
            (10**15, 'P'),
            (10**12, 'T'),
            (10** 9, 'G'),
            (10** 6, 'M'),
            (10** 3, 'k'),
            (1     , ' ')
        ]
    else:
        # Use IEC (2-based) units
        _abbrevs = [
            (1<<50L, 'Pi'),
            (1<<40L, 'Ti'),
            (1<<30L, 'Gi'),
            (1<<20L, 'Mi'),
            (1<<10L, 'Ki'),
            (1     , '  ')
        ]

    for factor, suffix in _abbrevs:
        if value >= factor:
            break

    if precision == 0:
        return "%3.d %s" % (int(value/factor), suffix)
    else:
        fmt="%%%d.%df %%s" % (4+precision, precision)
        return fmt % (float(value)/factor, suffix)


def iotest(fh, eof, blocksize=512, t=10):
    """io test"""

    io_num = 0
    start_ts = time.time()
    while time.time() < start_ts+t:
        io_num += 1
        # freebsd8: need 512B sector alignment and at least one whole block left
        pos = random.randint(0, eof - blocksize) & ~0x1ff
        fh.seek(pos)
        blockdata = fh.read(blocksize)
    end_ts = time.time()

    total_ts = end_ts - start_ts

    io_s = io_num/total_ts
    by_s = int(blocksize*io_num/total_ts)
    print " %sB blocks: %6.1f IOs/s, %sB/s (%sbit/s)" % (greek(blocksize), io_s,
        greek(by_s, 1), greek(8*by_s, 1, 'si'))

    return io_num/total_ts


if __name__ == '__main__':
    if len(sys.argv) < 2:
        usage()
        raise SystemExit

    dev = sys.argv[1]
    t = 10
    if len(sys.argv) == 3:
        t = int(sys.argv[2])

    blocksize = 512
    try:
        fh = open(dev, 'r')
        eof = mediasize(fh)

        print("%s, %sB:" % (dev, greek(eof, 2, 'si')))

        iops = 2
        while iops > 1 and blocksize < eof:
            iops = iotest(fh, eof, blocksize, t)
            blocksize *= 2
    except IOError, (err_no, err_str):
        raise SystemExit(err_str)
    except KeyboardInterrupt:
        print "caught ctrl-c, bye."

# eof.

