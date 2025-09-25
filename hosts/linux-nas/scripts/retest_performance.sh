#!/usr/bin/env bash

# Performance Retest Script - After Optimization
# Runs focused tests to measure optimization impact

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TEST_SIZE="1G"
RUNTIME="60"
LOG_DIR="/tmp/nas_retest_$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}NAS Performance Optimization Retest${NC}"
echo -e "${BLUE}=========================================${NC}"
echo "Comparing against baseline results"
echo "Test size: $TEST_SIZE per test"
echo "Runtime: $RUNTIME seconds per test"
echo "Log directory: $LOG_DIR"
echo ""

mkdir -p "$LOG_DIR"

# Check if fio is available
if ! command -v fio >/dev/null 2>&1; then
    echo -e "${RED}Error: fio is not installed or not in PATH${NC}"
    exit 1
fi

# Function to run focused fio test
run_focused_test() {
    local test_name="$1"
    local test_path="$2"
    local test_params="$3"
    local log_file="$LOG_DIR/${test_name}.log"

    echo -e "${YELLOW}=== Testing: $test_name ===${NC}"

    fio --name="$test_name" \
        --filename="$test_path/fio_retest_$$" \
        --size="$TEST_SIZE" \
        --runtime="$RUNTIME" \
        --time_based \
        --group_reporting \
        --output="$log_file" \
        $test_params

    if [ -f "$log_file" ]; then
        echo -e "${GREEN}Optimized Results:${NC}"
        grep -E "(read:|write:).*IOPS" "$log_file" | head -2
        echo ""
    fi

    rm -f "$test_path/fio_retest_$$"
}

echo -e "${BLUE}=== Optimization Impact Tests ===${NC}"
echo ""

# Test 1: ZFS Random I/O (Expected improvement from scheduler + ZFS tuning)
echo -e "${YELLOW}BASELINE: ZFS Random - 190 read IOPS, 48 write IOPS${NC}"
if [ -d "/mnt/media" ]; then
    run_focused_test "zfs_random_optimized" "/mnt/media" \
        "--ioengine=libaio --direct=0 --bs=64k --iodepth=16 --rw=randrw --rwmixread=80 --fsync=1"
else
    echo -e "${RED}Skipping - /mnt/media not available${NC}"
fi

# Test 2: ZFS Large Files (Expected improvement from prefetch tuning)
echo -e "${YELLOW}BASELINE: ZFS Large Files - 13.2 MB/s read, 32.1 MB/s write${NC}"
if [ -d "/mnt/media" ]; then
    run_focused_test "zfs_large_optimized" "/mnt/media" \
        "--ioengine=libaio --direct=0 --bs=1M --iodepth=4 --rw=rw --rwmixread=30 --fsync=1"
else
    echo -e "${RED}Skipping - /mnt/media not available${NC}"
fi

# Test 3: Multi-user workload (Expected improvement from vdev_max_active tuning)
echo -e "${YELLOW}BASELINE: Multi-user - 366 read IOPS, 125 write IOPS (4 jobs)${NC}"
if [ -d "/mnt/media" ]; then
    run_focused_test "multiuser_optimized" "/mnt/media" \
        "--ioengine=libaio --direct=0 --bs=64k --iodepth=8 --rw=randrw --rwmixread=75 --numjobs=4 --fsync=1"
else
    echo -e "${RED}Skipping - /mnt/media not available${NC}"
fi

# Test 4: Verify streaming performance maintained
echo -e "${YELLOW}BASELINE: Media Streaming - 7.5 GB/s (should maintain)${NC}"
if [ -d "/mnt/media" ]; then
    run_focused_test "streaming_check" "/mnt/media" \
        "--ioengine=libaio --direct=0 --bs=1M --iodepth=2 --rw=read --numjobs=8"
else
    echo -e "${RED}Skipping - /mnt/media not available${NC}"
fi

echo -e "${BLUE}=== Configuration Validation ===${NC}"

# Check I/O schedulers
echo -e "${YELLOW}I/O Scheduler Status:${NC}"
for drive in /dev/sd?; do
    if [ -e "$drive" ]; then
        scheduler=$(cat /sys/block/$(basename $drive)/queue/scheduler 2>/dev/null || echo "N/A")
        model=$(lsblk -d -o MODEL $drive 2>/dev/null | tail -n1 || echo "Unknown")
        echo "$(basename $drive) ($model): $scheduler"
    fi
done
echo ""

# Check ZFS parameters
echo -e "${YELLOW}ZFS Optimization Status:${NC}"
zfs_params=(
    "zfs_vdev_max_active"
    "zfs_top_maxinflight"
    "zfs_prefetch_disable"
    "zfs_txg_timeout"
    "zfs_dirty_data_max_percent"
)

for param in "${zfs_params[@]}"; do
    value=$(cat /sys/module/zfs/parameters/$param 2>/dev/null || echo "N/A")
    echo "$param: $value"
done

echo ""
echo -e "${BLUE}=== Performance Comparison Summary ===${NC}"
echo "Baseline vs Optimized Results:"
echo ""
echo "ZFS Random I/O:"
echo "  Baseline: 190 read IOPS, 48 write IOPS"
echo "  Target:   400+ read IOPS, 100+ write IOPS"
echo ""
echo "ZFS Large Files:"
echo "  Baseline: 13.2 MB/s read, 32.1 MB/s write"
echo "  Target:   50+ MB/s read, 60+ MB/s write"
echo ""
echo "Multi-user Workload:"
echo "  Baseline: 366 total read IOPS, 125 write IOPS"
echo "  Target:   600+ total read IOPS, 250+ write IOPS"
echo ""
echo "Media Streaming:"
echo "  Baseline: 7.5 GB/s (should maintain)"
echo ""
echo -e "${GREEN}Test logs saved to: $LOG_DIR${NC}"