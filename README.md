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
iops /dev/sda
iops --num-threads 8 --time 2 /dev/disk0
iops --num-threads 1 --block-size 512 --pattern sequential /dev/disk0
```
