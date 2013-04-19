#!/usr/bin/env python
#
# Copyright (c) 2008-2013 Benjamin Schweizer and others.
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
# John Keith Hohm <john at hohm dot net>
#
# Changes
# ~~~~~~~
# 2013-04-19, benjamin: support for non-root users
# 2011-02-10, john: added win32 support
# 2010-09-13, benjamin: increased num_threads default to 32 (max-ncq)
# 2010-09-01, benjamin: ioctl cleanup, improved freebsd support
# 2010-08-12, benjamin/uwe: added multi-threading support
# 2010-07-22, benjamin: fixed 32bit ioctls on bsd
# 2010-07-21, benjamin: freebsd/osx support, switched to isc license
# 2009-09-16, uwe: changed formatting, fixed last block bug
# 2008-10-16, benjamin: initial release
#
# Todo
# ~~~~
# - check/add netbsd/openbsd mediasize ioctls
#

USAGE = """Copyright (c) 2008-2013 Benjamin Schweizer and others.

usage:

    iops [-n|--num_threads threads] [-t|--time time] <device>

    threads := number of concurrent io threads, default 32
    time    := time in seconds, default 2
    device  := some block device, like /dev/sda or \\\\.\\PhysicalDrive0

example:

    iops /dev/sda
    iops -n 8 -t 2 /dev/disk0

"""

import sys
import os
import array
import struct
import random
import time
import threading

def mediasize(dev):
    """report the media size for a device, platform specific code"""
    # caching
    global _mediasizes
    if not '_mediasizes' in globals(): _mediasizes = {}
    if dev in _mediasizes:
        return _mediasizes[dev]

    mediasize = 0 # bytes
    mediasize =  os.stat(dev)[6] # works not for devices!

    if mediasize:
        pass
    elif sys.platform == 'darwin':
        # mac os x ioctl from sys/disk.h
        import fcntl
        DKIOCGETBLOCKSIZE = 0x40046418  # _IOR('d', 24, uint32_t)
        DKIOCGETBLOCKCOUNT = 0x40086419 # _IOR('d', 25, uint64_t)

        fh = open(dev, 'r')
        buf = array.array('B', range(0,4))  # uint32
        r = fcntl.ioctl(fh.fileno(), DKIOCGETBLOCKSIZE, buf, 1)
        blocksize = struct.unpack('I', buf)[0]
        buf = array.array('B', range(0,8))  # uint64
        r = fcntl.ioctl(fh.fileno(), DKIOCGETBLOCKCOUNT, buf, 1)
        blockcount = struct.unpack('Q', buf)[0]
        fh.close()
        mediasize = blocksize*blockcount

    elif sys.platform.startswith('freebsd'):
        # freebsd ioctl from sys/disk.h
        import fcntl
        DIOCGMEDIASIZE = 0x40086481 # _IOR('d', 129, uint64_t)

        fh = open(dev, 'r')
        buf = array.array('B', range(0,8))  # off_t / int64
        r = fcntl.ioctl(fh.fileno(), DIOCGMEDIASIZE, buf, 1)
        mediasize = struct.unpack('q', buf)[0]
        fh.close()

    elif sys.platform == 'win32':
        # win32 ioctl from winioctl.h, requires pywin32
        try:
            import win32file
        except ImportError:
            raise SystemExit("Package pywin32 not found, see http://sf.net/projects/pywin32/")
        IOCTL_DISK_GET_DRIVE_GEOMETRY = 0x00070000
        dh = win32file.CreateFile(dev, 0, win32file.FILE_SHARE_READ, None, win32file.OPEN_EXISTING, 0, None)
        info = win32file.DeviceIoControl(dh, IOCTL_DISK_GET_DRIVE_GEOMETRY, '', 24)
        win32file.CloseHandle(dh)
        (cyl_lo, cyl_hi, media_type, tps, spt, bps) = struct.unpack('6L', info)
        mediasize = ((cyl_hi << 32) + cyl_lo) * tps * spt * bps

    else: # linux or compat
        # linux 2.6 lseek from fcntl.h
        SEEK_SET=0
        SEEK_CUR=1
        SEEK_END=2

        fh = open(dev, 'r')
        fh.seek(0,SEEK_END)
        mediasize = fh.tell()
        fh.close()

    if not mediasize:
        raise Exception("cannot determine media size")

    _mediasizes[dev] = mediasize
    return mediasize

def greek(value, precision=0, prefix=None):
    """Return a string representing the IEC or SI suffix of a value"""
    # Copyright (c) 1999 Martin Pohl, copied from
    # http://mail.python.org/pipermail/python-list/1999-December/018519.html
    if prefix:
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


def iops(dev, blocksize=512, t=2):
    """measure input/output operations per second
    Perform random 512b aligned reads of blocksize bytes on fh for t seconds
    and print a stats line
    Returns: IOs/s
    """

    fh = open(dev, 'r')
    count = 0
    start = time.time()
    while time.time() < start+t:
        count += 1
        pos = random.randint(0, mediasize(dev) - blocksize) # need at least one block left
        #pos &= ~0x1ff   # freebsd8: pos needs 512B sector alignment
        pos &= ~(blocksize-1)   # sector alignment at blocksize
        fh.seek(pos)
        blockdata = fh.read(blocksize)
    end = time.time()

    t = end - start

    fh.close()

    return count/t


if __name__ == '__main__':
    # parse cli
    t = 2
    num_threads = 32
    dev = None

    if len(sys.argv) < 2:
        raise SystemExit(USAGE)

    while sys.argv:
        arg = sys.argv.pop(0)
        if arg in ['-n', '--num-threads']:
            num_threads = int(sys.argv.pop(0))
        elif arg in ['-t', '--time']:
            t = int(sys.argv.pop(0))
        else:
            dev = arg

    # run benchmark
    blocksize = 512
    try:
        print "%s, %sB, %d threads:" % (dev, greek(mediasize(dev), 2, 'si'), num_threads)
        _iops = num_threads+1 # initial loop
        while _iops > num_threads and blocksize < mediasize(dev):
            # threading boilerplate
            threads = []
            results = []
            
            def results_wrap(results, func, *__args, **__kw):
                """collect return values from func"""
                result = func(*__args, **__kw)
                results.append(result)

            for i in range(0, num_threads):
                _t = threading.Thread(target=results_wrap, args=(results, iops, dev, blocksize, t,))
                _t.start()
                threads.append(_t)

            for _t in threads:
                _t.join()
            _iops = sum(results)

            bandwidth = int(blocksize*_iops)
            print " %sB blocks: %6.1f IO/s, %sB/s (%sbit/s)" % (greek(blocksize), _iops,
                greek(bandwidth, 1), greek(8*bandwidth, 1, 'si'))

            blocksize *= 2
    except IOError, (err_no, err_str):
        raise SystemExit(err_str)
    except KeyboardInterrupt:
        print "caught ctrl-c, bye."

# eof.
