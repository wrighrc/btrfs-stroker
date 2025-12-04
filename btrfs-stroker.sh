#!/bin/bash
date

btrfs_path=/

declare -A tier_device_ids
tier_device_ids[0]="3 4 14 15"
tier_device_ids[1]="12 13"

# Unallocated Targets, this is in Bytes
# tier 0 device slack = 0
# tier 1 Unallocated = 100GiB 107374182400 Bytes
# tier 2 Unallocated =  60GiB  64424509440 Bytes
# tier 3 Unallocated =  40GiB  42949672960 Bytes
# tier 4 Unallocated =  20GiB  21474836480 Bytes

declare -A unallocated_targets
unallocated_targets[0]=0
unallocated_targets[1]=107374182400
unallocated_targets[2]=64424509440
unallocated_targets[3]=42949672960
unallocated_targets[4]=21474836480

#sudo btrfs balance start -dusage=85 $btrfs_path

for tier in ${!tier_device_ids[@]}
do
  for devid in $(shuf -e ${tier_device_ids[$tier]})
  do
    target=${unallocated_targets[$tier]}
    if [ "$target" -eq 0 ]
    then
      # this a special case, doesn't make sense to target 0 unallocated
      slack=$(sudo btrfs device usage -b $btrfs_path | grep -E '^/dev|slack' | grep -A1 "ID: ${devid}$" | tail -n 1 | awk '{print $3}')
      if [ "$slack" -ne 0 ]
      then
        printf "resizing tier$tier devid:$devid to max\n"
        sudo btrfs filesystem resize $devid:max $btrfs_path
      fi
      continue
    fi
    unallocated=$(sudo btrfs device usage -b $btrfs_path | grep -E '^/dev|Unallocated' | grep -A1 "ID: ${devid}$" | tail -n 1 | awk '{print $2}')
    difference=$((target - unallocated))
    #printf "$i : $tier4_target_unallocated_bytes - $unallocated = $difference\n"
    slack=$(sudo btrfs device usage -b $btrfs_path | grep -E '^/dev|slack' | grep -A1 "ID: ${devid}$" | tail -n 1 | awk '{print $3}')
    if [ "$difference" -ne 0 ]
    then
      if [ "$slack" -gt "$difference" ]
      then
        printf "resizing tier$tier devid:$devid by $difference bytes\n"
        if [ "$difference" -gt 0 ]
        then
          sudo btrfs filesystem resize $devid:+$difference $btrfs_path
        else
          sudo btrfs filesystem resize $devid:$difference $btrfs_path
        fi
      else
        printf "WARN: Didn't have enough slack to resize $devid:$difference $btrfs_path\n"
      fi
    fi
  done
done
