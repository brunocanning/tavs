#!/usr/bin/env bash

CLI_STATUS=xfs_db
CLI_DEFRAG=xfs_fsr
CLI_FSINFO=df

# Check the file system type
# The sed command converts end of line characters to spaces
for disk in $($CLI_FSINFO -t xfs | cut -f 1 -d ' ' | sed ':a;N;$!ba;s/\n/ /g'); do
  if [ $disk != "Filesystem" ]; then
    echo "Found xfs file system: $disk"
    fragstr=$($CLI_STATUS -r $disk -c frag)

    # Get the fragmentation ratio from the disk status string
    frag_ratio=$(echo $fragstr | cut -d ' ' -f 7 | sed 's/%//')
    # We will consider a ratio greater than 2 to be significant
    # AWK is used for floating point comparison which is not available in bash
    if [ $(awk "BEGIN {exit $frag_ratio >= 2 ? 0 : 1}") ]; then
      echo "Starting defragmentation on '$disk'"
      $CLI_DEFRAG $disk -t 1800	# Run for a maximum of 30 minutes
    else
      echo -e "Disk is not currently in need of defragmentation\n"
    fi
  fi
done
exit 0
