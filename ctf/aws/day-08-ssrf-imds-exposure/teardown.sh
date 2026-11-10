#!/usr/bin/env bash
# Safe public scaffold. Deliberately does not kill processes or delete files.
set -euo pipefail
echo "No resources were created by the public scaffold."
echo "No processes were stopped and no files were deleted."
echo "For a local implementation, track exact child PIDs and remove only lab-owned state."
