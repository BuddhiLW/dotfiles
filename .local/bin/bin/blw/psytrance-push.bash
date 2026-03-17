#!/usr/bin/env bash
# push_psytrance_dirs.sh
#
# Reads a list of directory names (one per line) and pushes each directory
# from ./mount/P/psytrance/<dir>/ to /sdcard/Music/psytrance/<dir>/ via adb.

set -euo pipefail

BASE_DIR="./mount/P/psytrance"
DEST_DIR="/sdcard/Music/psytrance"
LIST_FILE="psytrance_dirs.txt"   # change if needed
DRY_RUN=0

usage() {
  cat <<EOF
Usage: $0 [-f LIST_FILE] [-s BASE_DIR] [-d DEST_DIR] [--dry-run]
  -f  Path to list file (default: $LIST_FILE)
  -s  Source base directory (default: $BASE_DIR)
  -d  Destination base directory on device (default: $DEST_DIR)
  --dry-run  Show what would be pushed without doing it
EOF
}

# Parse args
while (( "$#" )); do
  case "$1" in
    -f) LIST_FILE="$2"; shift 2 ;;
    -s) BASE_DIR="$2"; shift 2 ;;
    -d) DEST_DIR="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

# Check adb connection
if ! adb get-state >/dev/null 2>&1; then
  echo "❌ Device not connected. Enable USB debugging and run: adb devices"
  exit 1
fi

# Ensure list exists
if [[ ! -f "$LIST_FILE" ]]; then
  echo "❌ List file not found: $LIST_FILE"
  exit 1
fi

echo "📂 Source base: $BASE_DIR"
echo "📱 Dest base:   $DEST_DIR"
echo "📝 List file:   $LIST_FILE"
(( DRY_RUN )) && echo "🔎 DRY RUN: no files will be pushed"

# Read list
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
  # Trim leading/trailing space
  ENTRY="${LINE#"${LINE%%[![:space:]]*}"}"
  ENTRY="${ENTRY%"${ENTRY##*[![:space:]]}"}"

  # Skip empty or commented lines
  [[ -z "$ENTRY" || "$ENTRY" =~ ^# ]] && continue

  # Strip surrounding single/double quotes if present
  if [[ "$ENTRY" =~ ^\".*\"$ || "$ENTRY" =~ ^\'.*\'$ ]]; then
    ENTRY="${ENTRY:1:-1}"
  fi

  SRC_DIR="${BASE_DIR}/${ENTRY}"

  if [[ ! -d "$SRC_DIR" ]]; then
    echo "⚠️  Skipping (not a directory): $SRC_DIR"
    continue
  fi

  # Pushing a directory to DEST_DIR preserves the directory name
  echo "➡️  Pushing directory: $SRC_DIR  →  $DEST_DIR/"
  if (( DRY_RUN )); then
    continue
  fi

  # -p shows progress, -a preserves timestamp/mode when possible
  if ! adb push -p -a "$SRC_DIR" "$DEST_DIR/"; then
    echo "❌ Failed to push: $SRC_DIR"
  fi
done < "$LIST_FILE"

echo "✅ Done."

