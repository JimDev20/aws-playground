#!/bin/bash

# --- Variables ---
PRODUCTS_JSON="Ecommerce/data/products.json"
IMAGES_DIR="Ecommerce/images/products"

# --- Function: log ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# --- Function: check one product's image ---
check_image() {
    local name="$1"
    local img="$2"
    local full_path="$IMAGES_DIR/$(basename "$img")"
    
    if [ -f "$full_path" ]; then
        return 0
    else
        log "MISSING: $name -> $img"
        return 1
    fi
}

# --- Main flow ---
log "=== Product Image Check ==="

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    log "ERROR: jq not installed. Run: sudo apt install jq"
    exit 1
fi

# Check if products.json exists
if [ ! -f "$PRODUCTS_JSON" ]; then
    log "ERROR: $PRODUCTS_JSON not found!"
    exit 1
fi

# Counters
total=0
found=0
missing=0

# Get total product count
total=$(jq 'length' "$PRODUCTS_JSON")
log "Total products in JSON: $total"

# Loop through each product
for i in $(seq 0 $((total - 1))); do
    name=$(jq -r ".[$i].name" "$PRODUCTS_JSON")
    img=$(jq -r ".[$i].img" "$PRODUCTS_JSON")
    
    if check_image "$name" "$img"; then
        found=$((found + 1))
    else
        missing=$((missing + 1))
    fi
done

# Summary
log "=== Check Complete ==="
log "Total: $total | Found: $found | Missing: $missing"

if [ $missing -gt 0 ]; then
    log "WARNING: $missing product(s) have missing images!"
    exit 1
else
    log "All product images accounted for!"
    exit 0
fi
