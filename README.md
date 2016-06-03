iops
=====
iops is an IO benachmark tool that performs random reads on block devices.
If an exact block size is not specified using -b, the the size starts with
the physical sector size (defaulting to 4k) and doubles every iteration of
the loop. You can switch the read pattern using -p toggle.

Usage
-----
```
iops [-n|--num-threads threads] [-t|--time time] [-m|--machine-readable]
     [-b|--block-size size] [-p|--pattern random|sequential] <device>

num-threads         := number of concurrent io threads, default 32
time                := time in seconds, default 2
machine-readable    := used to switch off conversion into MiB and other SI units
block-size          := block size (should be a multiple of 512)
pattern             := random|sequential
device              := some block device, like /dev/sda or \\\\.\\PhysicalDrive0
```

Examples
--------
```
$ iops /dev/sda
/dev/sda,   3.00 T, sectorsize=512B, #threads=32, pattern=random:
 512  B blocks:   79.6 IO/s,  40.8 kB/s (326.2 kbit/s)
   1 kB blocks:   62.3 IO/s,  63.8 kB/s (510.1 kbit/s)
   2 kB blocks:   58.6 IO/s, 120.0 kB/s (959.8 kbit/s)
   4 kB blocks:   49.0 IO/s, 200.6 kB/s (  1.6 Mbit/s)
   8 kB blocks:   55.5 IO/s, 454.3 kB/s (  3.6 Mbit/s)
  16 kB blocks:   59.9 IO/s, 981.3 kB/s (  7.9 Mbit/s)
  32 kB blocks:   60.7 IO/s,   2.0 MB/s ( 15.9 Mbit/s)
  65 kB blocks:   53.4 IO/s,   3.5 MB/s ( 28.0 Mbit/s)
 131 kB blocks:   43.7 IO/s,   5.7 MB/s ( 45.8 Mbit/s)
 262 kB blocks:   45.5 IO/s,  11.9 MB/s ( 95.5 Mbit/s)
 524 kB blocks:   28.5 IO/s,  14.9 MB/s (119.5 Mbit/s)
   1 MB blocks:   22.1 IO/s,  23.2 MB/s (185.2 Mbit/s)
   2 MB blocks:   18.4 IO/s,  38.7 MB/s (309.3 Mbit/s)
   4 MB blocks:    9.2 IO/s,  38.5 MB/s (308.2 Mbit/s)
   8 MB blocks:    6.6 IO/s,  55.1 MB/s (440.7 Mbit/s)

$ iops /dev/vda
/dev/vda,  34.36 GB, 32 threads:
 512   B blocks:  374.1 IO/s, 187.0 KiB/s (  1.5 Mbit/s)
   1 KiB blocks:  322.6 IO/s, 322.6 KiB/s (  2.6 Mbit/s)
   2 KiB blocks:  285.6 IO/s, 571.2 KiB/s (  4.7 Mbit/s)
   4 KiB blocks:  268.3 IO/s,   1.0 MiB/s (  8.8 Mbit/s)
   8 KiB blocks:  270.1 IO/s,   2.1 MiB/s ( 17.7 Mbit/s)
  16 KiB blocks:  227.0 IO/s,   3.5 MiB/s ( 29.8 Mbit/s)
  32 KiB blocks:  212.0 IO/s,   6.6 MiB/s ( 55.6 Mbit/s)
  64 KiB blocks:  157.0 IO/s,   9.8 MiB/s ( 82.3 Mbit/s)
 128 KiB blocks:  137.7 IO/s,  17.2 MiB/s (144.4 Mbit/s)
 256 KiB blocks:   99.0 IO/s,  24.8 MiB/s (207.7 Mbit/s)
 512 KiB blocks:   66.9 IO/s,  33.5 MiB/s (280.8 Mbit/s)
   1 MiB blocks:   44.7 IO/s,  44.7 MiB/s (375.2 Mbit/s)
   2 MiB blocks:   22.3 IO/s,  44.7 MiB/s (375.0 Mbit/s)

$ iops --num-threads 8 --time 2 /dev/disk0
/dev/disk0, 251.00 G, sectorsize=512B, #threads=8, pattern=random:
 512  B blocks: 38917.8 IO/s,  19.9 MB/s (159.4 Mbit/s)
   1 kB blocks: 39416.6 IO/s,  40.4 MB/s (322.9 Mbit/s)
   2 kB blocks: 40357.8 IO/s,  82.7 MB/s (661.2 Mbit/s)
   4 kB blocks: 33269.5 IO/s, 136.3 MB/s (  1.1 Gbit/s)
   8 kB blocks: 24222.6 IO/s, 198.4 MB/s (  1.6 Gbit/s)
  16 kB blocks: 18491.4 IO/s, 303.0 MB/s (  2.4 Gbit/s)
  32 kB blocks: 10398.7 IO/s, 340.7 MB/s (  2.7 Gbit/s)
  65 kB blocks: 5611.3 IO/s, 367.7 MB/s (  2.9 Gbit/s)
 131 kB blocks: 2884.1 IO/s, 378.0 MB/s (  3.0 Gbit/s)
 262 kB blocks: 1479.3 IO/s, 387.8 MB/s (  3.1 Gbit/s)
 524 kB blocks:  714.0 IO/s, 374.3 MB/s (  3.0 Gbit/s)
   1 MB blocks:  370.3 IO/s, 388.3 MB/s (  3.1 Gbit/s)
   2 MB blocks:  187.4 IO/s, 393.1 MB/s (  3.1 Gbit/s)
   4 MB blocks:   90.2 IO/s, 378.4 MB/s (  3.0 Gbit/s)
   8 MB blocks:   44.4 IO/s, 372.7 MB/s (  3.0 Gbit/s)
  16 MB blocks:   22.1 IO/s, 371.1 MB/s (  3.0 Gbit/s)
  33 MB blocks:   12.4 IO/s, 416.7 MB/s (  3.3 Gbit/s)
  67 MB blocks:    6.1 IO/s, 408.2 MB/s (  3.3 Gbit/s)
 134 MB blocks:    2.9 IO/s, 394.7 MB/s (  3.2 Gbit/s)
 268 MB blocks:    1.3 IO/s, 343.3 MB/s (  2.7 Gbit/s)

$ iops --time 10 --num-threads 1 --block-size 16768 --pattern sequential /dev/disk0
/dev/disk0, 251.00 G, sectorsize=512B, #threads=1, pattern=sequential:
  16 kB blocks: 7815.2 IO/s, 131.0 MB/s (  1.0 Gbit/s)
```

Links
-----
- http://www.linux-magazin.de/Ausgaben/2016/03/I-O-Benchmarking (German)
- http://www.admin-magazine.com/Archive/2016/32/Fundamentals-of-I-O-benchmarking (English)
