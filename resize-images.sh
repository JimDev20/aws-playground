#!/bin/bash

# --- Variables ---
SOURCE_DIR="Ecommerce/images/products"
OUTPUT_DIR="Ecommerce/images/products/resized"
MAX_WIDTH=800

# --- Function: log ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# --- Function: resize one image ---
resize_image() {
    local input="$1"
    local filename=$(basename "$input")
    local output="$OUTPUT_DIR/$filename"
    
    convert "$input" -resize ${MAX_WIDTH}x -quality 85 "$output"
    
    if [ $? -eq 0 ]; then
        log "OK: $filename"
        return 0
    else
        log "FAIL: $filename"
        return 1
    fi
}

# --- Main flow ---
log "=== Image Resize Start ==="

# Check if imagemagick is installed
if ! command -v convert &> /dev/null; then
    log "ERROR: imagemagick not installed. Run: sudo apt install imagemagick"
    exit 1
fi

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    log "ERROR: Source directory '$SOURCE_DIR' not found!"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Counters
total=0
success=0
failed=0

# Loop through all images
for img in "$SOURCE_DIR"/*.{jpg,jpeg,png}; do
    [ -e "$img" ] || continue
    total=$((total + 1))
    
    if resize_image "$img"; then
        success=$((success + 1))
    else
        failed=$((failed + 1))
    fi
done

# Summary
log "=== Resize Complete ==="
log "Total: $total | Success: $success | Failed: $failed"
log "Resized images saved to: $OUTPUT_DIR"

exit 0
