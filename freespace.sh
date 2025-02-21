#!/bin/bash
set -e

# Configurable required space in KiB (850GB * 1024 * 1024)
reqSpace=$((850 * 1024 * 1024))  # 850 GB in KiB

# Default torrent size to 0 if not provided
torrentSizeBytes=0
LOG_FILE="$HOME/sizecheck.log"

# Function to print help
print_help() {
  echo "Usage: $0 --size <torrent_size_in_bytes>"
  exit 1
}

# Function to log messages with timestamps
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --size)
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                torrentSizeBytes="$2"
                shift
            else
                echo "Error: --size requires a valid numeric value in bytes."
                exit 1
            fi
            ;;
        --help|-h)
            print_help
            ;;
        *)
            echo "Unknown parameter passed: $1"
            print_help
            ;;
    esac
    shift
done

# Validate that size was provided
if [[ "$torrentSizeBytes" -eq 0 ]]; then
    echo "Error: Torrent size must be provided with --size (in bytes)"
    print_help
fi

# Convert torrent size from bytes to KiB
torrentSizeKiB=$((torrentSizeBytes / 1024))

# Calculate used space in Downloads using du (in KiB)
SPACE=$(find "$HOME/Downloads" -user oz1r69tk -print0 | du --files0-from=- -sk | awk '{sum += $1} END {print sum}')

# Calculate the total required space after adding the torrent
totalRequiredSpace=$((SPACE + torrentSizeKiB))

# Convert sizes for display
SPACE_GB=$(echo "scale=2; $SPACE / (1024 * 1024)" | bc)
torrentSize_GB=$(echo "scale=2; $torrentSizeBytes / (1024 * 1024 * 1024)" | bc)
totalRequiredSpace_GB=$(echo "scale=2; $totalRequiredSpace / (1024 * 1024)" | bc)
reqSpace_GB=$(echo "scale=2; $reqSpace / (1024 * 1024)" | bc)

# Log details
log "----------------------------------"
log "Torrent Size: ${torrentSize_GB} GB ($torrentSizeBytes bytes)"
log "Current Used Space: ${SPACE_GB} GB ($SPACE KiB)"
totalUsedPercent=$(echo "scale=2; $SPACE / $reqSpace * 100" | bc)
log "Total Used: $totalUsedPercent%"
totalUsedPercentNew=$(echo "scale=2; $totalRequiredSpace / $reqSpace * 100" | bc)
log "Total Used if Added: $totalUsedPercentNew%"

# Check if the total required space exceeds allowed space
if [[ $totalRequiredSpace -ge $reqSpace ]]; then
    log "Error: Adding the torrent would exceed allowed free space."
    echo "Error: Not enough space. Torrent cannot be added."
    exit 1
fi

log "Sufficient space available. Proceeding to add torrent."
echo "Adding Torrent"
exit 0
