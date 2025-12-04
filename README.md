# btrfs-stroker
For stroking your btrfs (as if you needed a reason)

## Motivation
It would be great if btrfs did auto tiering but it doesn't.   I've tried using lvm-cache as a work around but that didn't work out so well.

So instead I just use raid 1 with varying sized/speed devices, making one big happy btrfs volume.

BTRFS will allocate space from the drives with the most available space so if I create a volume with
2x2TB NVME drives
2x6TB SLOW HDDs
Btrfs would fill up 4TB on the 2 6TB drives, and only then start using the NVME drives.

Instead of doing that, I would rather use the NVME drives space first and then start using the slow drives.

Basically I can just resize the 6TB drives, trying to maintain 100 Gigabytes of unallocated space by
running the btrfs-stroker script once a day to resize the slower devices as more space is needed, I just want to keep enough 
free space available to not have my volume fill up before the script can stroke it.

(Ofcourse one could stroke their btrfs more than once a day if needed.)

The script lets you define Tiers of Drives you want to use up first, with Tier 0 being the ones you want to use first.

So you could install something like this.

Tier 0 - 2x 2 TB NVME Drives running at PCIe 4x

Tier 1 - 2x 500 GB NVME Drives running at PCIe 1x

Tier 2 - 2x 6 TB 7200 RPM Enterprise Drives

Tier 3 - 2x 500 GB 5400 RPM Hybrid Laptop Drives

## Temporary flip to ingest files on the slow devices.

One could just manually set max on the slow drives supposing they wanted new bulk data incoming to land on the slow drives, like this
```
$ cat set-max.sh
#!/bin/bash -x
sudo btrfs filesystem resize 12:max /
sudo btrfs filesystem resize 13:max /
```
And then let the script change that the next time it runs.

## Note about short stroking
Since hardrives perform better on the first bits of the drive, btrfs-stroker balances off the slowest parts of the drive, so the idea is that if you delete stuff it will ensure the fast drives are used and the fastest parts of the slow drive are used.

See https://www.tomshardware.com/reviews/short-stroking-hdd,2157-2.html for info on short stroking.
