#!/bin/bash

# --- Variables ---
SOURCE="Ecommerce"
DEST="/var/www/Ecommerce"
LOG_FILE="deploy.log"

# --- Function: log with timestamp ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# --- Function: check if directory exists ---
check_source() {
    if [ ! -d "$SOURCE" ]; then
        log "ERROR: Source directory '$SOURCE' not found!"
        exit 1
    fi
    log "Source directory found: $SOURCE"
}

# --- Function: deploy ---
deploy() {
    log "Starting deployment..."
    sudo mkdir -p "$DEST"
    sudo cp -r "$SOURCE"/* "$DEST/"
    
    if [ $? -eq 0 ]; then
        log "SUCCESS: Deployed to $DEST"
    else
        log "ERROR: Deployment failed!"
        exit 1
    fi
}

# --- Function: count deployed files ---
count_files() {
    local total=$(find "$DEST" -type f | wc -l)
    log "Total files deployed: $total"
}

# --- Main flow ---
log "=== Uncle George Ecommerce Deployment ==="
check_source
deploy
count_files
log "=== Deployment Complete ==="
