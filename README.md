# btrfs-stroker
For stroking your btrfs (as if you needed a reason)

## Motivation
My PC has one btrfs volume that uses raid1 with any old junk I can pack into it for storage.

BTRFS will allocate space from the drives with the most available space so if I create a volume with
2x2TB NVME drives
2x6TB SLOW HDDs
Btrfs will fill up 4TB on the 2 6TB drives, and then start using the NVME drives.

Instead of doing that, I would rather use the NVME drives space first and then start using the other drives.
Basically we can just resize the 6TB drives, trying to maintain 100 Gigabytes of unallocated space by
running btrfs-stroker once a day to resize the slower devices as more space is needed, we just want to keep enough 
free space available to not have our volume fill up before we can stroke it.

Ofcourse one could stroke their btrfs more than once a day if needed.

Lets define Tiers of Drives we want to use up first, with Tier 0 being the one we want to use first.

Tier 0 - 2x 2 TB NVME Drives running at PCIe 4x
Tier 1 - 2x 500 GB NVME Drives running at PCIe 1x
Tier 2 - 2x 6 TB 7200 RPM Enterprise Drives
Tier 3 - 2x 500 GB 5400 RPM Hybrid Laptop Drives
