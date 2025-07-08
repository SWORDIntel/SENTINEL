zfssnapshot() {
  # Check if a snapshot name prefix is provided
  if [ -z "$1" ]; then
    echo "Usage: zfssnapshot <snapshot_name_prefix>"
    return 1
  fi

  PREFIX="$1"
  # IMPORTANT: Determine the correct POOL_NAME and DATASET_PATH for your system.
  # These are common defaults but might need adjustment.
  POOL_NAME="rpool"
  DATASET_PATH="${POOL_NAME}/ROOT/LONENOMAD"
  DATETIME=$(date +"%m-%d-%Y-%H%M")
  SNAPSHOT_NAME="${DATASET_PATH}@${PREFIX}${DATETIME}"

  echo "Creating snapshot: ${SNAPSHOT_NAME}"
  # Ensure you have sudo privileges for these commands, or run as root.
  # You might need to configure passwordless sudo for these specific commands
  # if you intend to run this as a non-root user without password prompts.
  sudo zfs snapshot "${SNAPSHOT_NAME}"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create snapshot ${SNAPSHOT_NAME}"
    return 1
  fi

  echo ""
  echo "Successfully created snapshot: ${SNAPSHOT_NAME}"
  echo ""
  echo "Listing available snapshots for ${DATASET_PATH} (newest first):"
  sudo zfs list -t snapshot -o name -S creation "${DATASET_PATH}"

  return 0
}

source ~/datascience/envs/dsenv/bin/activate
alias @aliases='alias'
