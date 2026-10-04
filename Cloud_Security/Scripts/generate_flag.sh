#!/usr/bin/env bash
#
# generate_flag.sh
#
# Creates a random flag in an S3 bucket or deletes the previously created flag.
# Usage:
#   ./generate_flag.sh
#
# The script keeps track of the key of the last created flag in ~/.last_flag_key so you can delete it later.
# It also creates a dummy flag in a separate sub-path for mislead testing.

set -euo pipefail

# ------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------
# Default bucket name: you can set S3_BUCKET env var before running or
# the script will prompt you for it.
: "${S3_BUCKET:=}"

# Location where we keep the key of the last created flag
LAST_KEY_FILE="$HOME/.last_flag_key"

# ------------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------------
random_flag() {
  # Generates a pseudo‑unique flag string
  local rand="$(openssl rand -hex 16)"
  echo "FLAG{${rand}}"
}

random_key() {
  # Put the flag in a random UUID sub‑folder
  local uuid=$(cat /proc/sys/kernel/random/uuid)
  echo "flags/${uuid}/flag.txt"
}

upload_flag() {
  local flag_text=$1
  local key=$2
  echo "Uploading flag to s3://$S3_BUCKET/$key ..."
  printf '%s
' "$flag_text" | aws s3 --region ap-south-2 cp - "s3://$S3_BUCKET/$key"
  echo "✅ Flag uploaded to $S3_BUCKET/$key"
}

upload_dummy() {
  local key=$2
  echo "Uploading dummy flag to s3://$S3_BUCKET/$key ..."
  printf '%s
' "FLAG{dummy}" | aws s3 --region ap-south-2 cp - "s3://$S3_BUCKET/$key"
  echo "✅ Dummy flag uploaded to $S3_BUCKET/$key"
}

delete_key() {
  local key=$1
  echo "Removing $S3_BUCKET/$key ..."
  aws s3 --region ap-south-2 rm "s3://$S3_BUCKET/$key"
  echo "✅ Deleted $key"
}

# ------------------------------------------------------------------
# Main logic
# ------------------------------------------------------------------

echo "";
echo "=== Flag‑Generator S3 Helper ===";
echo "";

if [[ -z "$S3_BUCKET" ]]; then
  read -rp "Enter target bucket name: " S3_BUCKET
  if [[ -z "$S3_BUCKET" ]]; then
    echo "❌ Bucket name required. Exiting.";
    exit 1
  fi
fi

echo "";
echo "Choose an option:";
echo "1) Create a new random flag (and a dummy flag)";
echo "2) Delete the previously created flag";
read -rp "Option [1-2]: " choice

case "$choice" in
  1)
    # --- Create ---------------------------------------------------
    FLAG_TEXT=$(random_flag)
    KEY=$(random_key)
    upload_flag "$FLAG_TEXT" "$KEY"
    echo "$KEY" > "$LAST_KEY_FILE"
    echo "📍 Stored key locally: $LAST_KEY_FILE"
    DUMMY_KEY="dummy/$(cat /proc/sys/kernel/random/uuid)/dummy.txt"
    upload_dummy "$DUMMY_KEY"
    echo "";
    echo "🎉 Done. Your flag is: $FLAG_TEXT";
    echo "It can be retrieved by downloading s3://$S3_BUCKET/$KEY";
    ;;
  2)
    # --- Delete ---------------------------------------------------
    if [[ ! -f "$LAST_KEY_FILE" ]]; then
      echo "❌ No record of a previous flag. Nothing to delete.";
      exit 1;
    fi
    KEY=$(<"$LAST_KEY_FILE")
    delete_key "$KEY"
    rm -f "$LAST_KEY_FILE"
    echo "🗑️  Removed local record of last flag.";
    ;;
  *)
    echo "❌ Invalid option. Exiting.";
    exit 1;
    ;;
esac

echo "";
echo "💡 Remember: the dummy flag stays in $S3_BUCKET/dummy/ for mis‑direction.";
echo "   You can delete it manually via:";
echo "   aws s3 rm s3://$S3_BUCKET/dummy/ --recursive"
