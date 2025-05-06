#!/bin/sh

# Update as necessary
readonly rclone_remote='' # Run "rclone listremotes" on your computer and fill it here
readonly bin_dir='/mnt/onboard/.adds/onlinepull' # Do not change unless you deviated from the guide
readonly usb_root='/mnt/onboard' # You probably will not want to change this
readonly book_library="${usb_root}/Books" # Choose the folder to download files to

###############################
## LEAVE UNTOUCHED FROM HERE ##
###############################

# Action ("copy" or "sync")
readonly rclone_action="${1}"

# If already running, kill previous and wait
pkill rclone && sleep 5

# General cleanup of partial files and macOS junk
find "${book_library}" -name '*partial' -delete
find "${book_library}" -name '._*' -delete
rm -rf "${usb_root}/.Trashes"
rm -rf "${usb_root}/.Spotlight-V100"
rm -rf "${usb_root}/._$(basename "${book_library}")"

# Wait for a confirmed internet connection
while [[ "${retries:=10}" -gt 0 ]]
do
  ping -c 1 -w 3 '1.1.1.1' && break

  sleep 1
  retries="$((retries - 1))"
done

if [[ "${retries}" -le 0 ]]
then
  qndb --method mwcToast 3000 "Failed to connect to the internet!"
  exit 1
fi

# Current library state
readonly library_oldsum="$(ls -laR "${book_library}" | md5sum)"

# Download
qndb --method mwcToast 1000 'Starting Dropbox download...'

if ! "${bin_dir}/rclone" \
  --ca-cert "${bin_dir}/cacert.pem" \
  --log-file "${bin_dir}/rclone.log" \
  --ignore-checksum --size-only \
  --verbose \
  "${rclone_action}" "${rclone_remote}" "${book_library}"
then
  qndb --method mwcToast 3000 "Error in download!"
  exit 1
fi

# Rescan library only if something changed
readonly library_newsum="$(ls -laR "${book_library}" | md5sum)"

[[ "${library_oldsum}" != "${library_newsum}" ]] && qndb --method pfmRescanBooksFull || qndb --method mwcToast 100 'Nothing new'

# Update rclone
"${bin_dir}/rclone" \
  --ca-cert "${bin_dir}/cacert.pem" \
  --log-file "${bin_dir}/rclone.log" \
  selfupdate

# Truncate log length
tail -n 200 "${bin_dir}/rclone.log" > "${bin_dir}/trimmed.log"
mv "${bin_dir}/trimmed.log" "${bin_dir}/rclone.log"
