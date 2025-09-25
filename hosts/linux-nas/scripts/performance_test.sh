#!/usr/bin/env bash

# NAS Performance Baseline Testing Script
# HP MicroServer Gen8 with ZFS storage
# Uses fio for comprehensive disk performance analysis

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
TEST_SIZE="1G"
RUNTIME="60"
LOG_DIR="/tmp/nas_performance_$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}NAS Performance Baseline Testing${NC}"
echo -e "${BLUE}=========================================${NC}"
echo "Test size: $TEST_SIZE per test"
echo "Runtime: $RUNTIME seconds per test"
echo "Log directory: $LOG_DIR"
echo ""

# Create log directory
mkdir -p "$LOG_DIR"

# Check if fio is available
if ! command -v fio >/dev/null 2>&1; then
    echo -e "${RED}Error: fio is not installed or not in PATH${NC}"
    echo "Install with: nix-shell -p fio"
    exit 1
fi

# Function to run fio test
run_fio_test() {
    local test_name="$1"
    local test_path="$2"
    local test_params="$3"
    local log_file="$LOG_DIR/${test_name}.log"

    echo -e "${YELLOW}=== Running: $test_name ===${NC}"
    echo "Target: $test_path"
    echo "Parameters: $test_params"
    echo "Log: $log_file"
    echo ""

    # Run the test
    fio --name="$test_name" \
        --filename="$test_path/fio_test_$$" \
        --size="$TEST_SIZE" \
        --runtime="$RUNTIME" \
        --time_based \
        --group_reporting \
        --output="$log_file" \
        $test_params

    # Extract key metrics
    if [ -f "$log_file" ]; then
        echo -e "${GREEN}Results for $test_name:${NC}"
        grep -E "(read:|write:).*IOPS" "$log_file" || echo "IOPS data not found"
        grep -E "(read:|write:).*BW=" "$log_file" || echo "Bandwidth data not found"
        echo ""
    fi

    # Clean up test file
    rm -f "$test_path/fio_test_$$"
}

echo -e "${BLUE}=== Phase 1: SSD Performance (ZFS Root Pool) ===${NC}"

# Test 1: SSD Random Read/Write (4K)
run_fio_test "ssd_random_4k" "/tmp" \
    "--ioengine=libaio --direct=1 --bs=4k --iodepth=32 --rw=randrw --rwmixread=70"

# Test 2: SSD Sequential Read/Write
run_fio_test "ssd_sequential" "/tmp" \
    "--ioengine=libaio --direct=1 --bs=1M --iodepth=4 --rw=rw --rwmixread=50"

echo -e "${BLUE}=== Phase 2: Individual HDD Performance ===${NC}"

# Test 3: Single HDD Random Read/Write (4K)
echo -e "${YELLOW}Testing individual HDD performance on /dev/sda${NC}"
run_fio_test "hdd_random_4k" "/tmp" \
    "--ioengine=libaio --direct=1 --bs=4k --iodepth=8 --rw=randrw --rwmixread=70"

# Test 4: Single HDD Sequential Read/Write
run_fio_test "hdd_sequential" "/tmp" \
    "--ioengine=libaio --direct=1 --bs=1M --iodepth=4 --rw=rw --rwmixread=50"

echo -e "${BLUE}=== Phase 3: ZFS Storage Pool Performance ===${NC}"

# Test 5: ZFS Dataset Random I/O (NAS workload simulation)
if [ -d "/mnt/media" ]; then
    run_fio_test "zfs_nas_random" "/mnt/media" \
        "--ioengine=libaio --direct=0 --bs=64k --iodepth=16 --rw=randrw --rwmixread=80 --fsync=1"
else
    echo -e "${YELLOW}Skipping ZFS dataset test - /mnt/media not available${NC}"
fi

# Test 6: ZFS Dataset Sequential I/O (large file transfers)
if [ -d "/mnt/media" ]; then
    run_fio_test "zfs_large_files" "/mnt/media" \
        "--ioengine=libaio --direct=0 --bs=1M --iodepth=4 --rw=rw --rwmixread=30 --fsync=1"
else
    echo -e "${YELLOW}Skipping ZFS large file test - /mnt/media not available${NC}"
fi

echo -e "${BLUE}=== Phase 4: Mixed Workload Scenarios ===${NC}"

# Test 7: Multi-threaded NAS simulation
if [ -d "/mnt/media" ]; then
    run_fio_test "nas_multiuser" "/mnt/media" \
        "--ioengine=libaio --direct=0 --bs=64k --iodepth=8 --rw=randrw --rwmixread=75 --numjobs=4 --fsync=1"
else
    echo -e "${YELLOW}Skipping multi-user test - /mnt/media not available${NC}"
fi

# Test 8: Streaming workload (media server simulation)
if [ -d "/mnt/media" ]; then
    run_fio_test "media_streaming" "/mnt/media" \
        "--ioengine=libaio --direct=0 --bs=1M --iodepth=2 --rw=read --numjobs=8"
else
    echo -e "${YELLOW}Skipping streaming test - /mnt/media not available${NC}"
fi

echo -e "${BLUE}=== Performance Test Complete ===${NC}"
echo ""
echo -e "${GREEN}Summary Report:${NC}"
echo "All test logs saved to: $LOG_DIR"
echo ""
echo -e "${YELLOW}Key files to review:${NC}"
ls -la "$LOG_DIR"
echo ""
echo -e "${BLUE}=== Quick Analysis ===${NC}"

# Generate summary
summary_file="$LOG_DIR/performance_summary.txt"
{
    echo "NAS Performance Test Summary - $(date)"
    echo "========================================="
    echo ""

    for log in "$LOG_DIR"/*.log; do
        if [ -f "$log" ]; then
            test_name=$(basename "$log" .log)
            echo "=== $test_name ==="
            grep -E "(read:|write:).*IOPS.*BW=" "$log" | head -2
            echo ""
        fi
    done

    echo "Hardware Configuration:"
    echo "- Platform: HP MicroServer Gen8"
    echo "- Root Pool: ZFS on 500GB SSD"
    echo "- Storage Pool: ZFS RAIDZ1 on 4x4TB HDDs"
    echo "- Memory: 16GB with 4GB ZFS ARC limit"
    echo ""
    echo "Test Configuration:"
    echo "- Test size: $TEST_SIZE per job"
    echo "- Runtime: $RUNTIME seconds"
    echo "- Direct I/O for raw disk tests"
    echo "- Buffered I/O for ZFS tests (with fsync)"

} > "$summary_file"

echo "Performance summary saved to: $summary_file"
echo ""
echo -e "${GREEN}To analyze results:${NC}"
echo "cat $summary_file"
echo ""
echo -e "${BLUE}=========================================${NC}"