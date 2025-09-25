#!/usr/bin/env bash

# Queue Depth and Drive Analysis Script
# For HP MicroServer Gen8 NAS performance testing

echo "========================================="
echo "NAS Drive Queue Depth Analysis"
echo "========================================="
echo

# Check current queue depth for all drives
echo "=== Queue Depth Settings ==="
for drive in /dev/sd?; do
  if [ -e "$drive" ]; then
    echo "=== $drive ==="
    echo "Queue depth: $(cat /sys/block/$(basename $drive)/queue/nr_requests 2>/dev/null || echo 'N/A')"
    echo "Max queue depth: $(cat /sys/block/$(basename $drive)/queue/max_sectors_kb 2>/dev/null || echo 'N/A') KB"
    echo "Scheduler: $(cat /sys/block/$(basename $drive)/queue/scheduler 2>/dev/null || echo 'N/A')"
    echo "Rotational: $(cat /sys/block/$(basename $drive)/queue/rotational 2>/dev/null || echo 'N/A')"
    echo "Read-ahead: $(cat /sys/block/$(basename $drive)/queue/read_ahead_kb 2>/dev/null || echo 'N/A') KB"
    echo
  fi
done

echo "=== NCQ (Native Command Queueing) Support ==="
for drive in /dev/sd?; do
  if [ -e "$drive" ]; then
    echo "=== $drive ==="
    echo "Drive model: $(lsblk -d -o NAME,MODEL $drive 2>/dev/null | tail -n1 | cut -d' ' -f2- || echo 'N/A')"

    # Check NCQ support via hdparm
    if command -v hdparm >/dev/null 2>&1; then
      ncq_info=$(sudo hdparm -I $drive 2>/dev/null | grep -i queue)
      if [ -n "$ncq_info" ]; then
        echo "NCQ info: $ncq_info"
      else
        echo "NCQ info: Not available or not supported"
      fi
    else
      echo "hdparm not available"
    fi

    # Check write cache status
    if command -v hdparm >/dev/null 2>&1; then
      write_cache=$(sudo hdparm -W $drive 2>/dev/null | grep "write-caching")
      echo "Write cache: $write_cache"
    fi
    echo
  fi
done

echo "=== Drive Performance Characteristics ==="
for drive in /dev/sd?; do
  if [ -e "$drive" ]; then
    echo "=== $drive ==="

    # Get drive size and type
    size=$(lsblk -d -o SIZE $drive 2>/dev/null | tail -n1 || echo 'N/A')
    type=$(cat /sys/block/$(basename $drive)/queue/rotational 2>/dev/null)
    if [ "$type" = "1" ]; then
      drive_type="HDD (spinning)"
    elif [ "$type" = "0" ]; then
      drive_type="SSD"
    else
      drive_type="Unknown"
    fi

    echo "Size: $size"
    echo "Type: $drive_type"
    echo "Physical block size: $(cat /sys/block/$(basename $drive)/queue/physical_block_size 2>/dev/null || echo 'N/A') bytes"
    echo "Logical block size: $(cat /sys/block/$(basename $drive)/queue/logical_block_size 2>/dev/null || echo 'N/A') bytes"
    echo
  fi
done

echo "=== ZFS Pool Status ==="
if command -v zpool >/dev/null 2>&1; then
  echo "--- Root Pool (rpool) ---"
  sudo zpool status rpool 2>/dev/null || echo "rpool not available"
  echo
  echo "--- Storage Pool (storage) ---"
  sudo zpool status storage 2>/dev/null || echo "storage not available"
else
  echo "ZFS not available"
fi

echo "========================================="
echo "Analysis complete. Review the output above for:"
echo "- Queue depths (typically 32-128 for modern drives)"
echo "- NCQ support (should show queue depth > 1)"
echo "- Write caching enabled"
echo "- Appropriate I/O schedulers"
echo "========================================="