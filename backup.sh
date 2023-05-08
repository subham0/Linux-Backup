#!/bin/bash

CB_COUNTER=20001
IB_COUNTER=10001
backup_dir="$HOME/home/backup"
cb_dir="${backup_dir}/cb"
ib_dir="${backup_dir}/ib"
if [ -d "$backup_dir" ]; then
  echo "Previous Backup Directory $dir_to_delete found. Deleting..."
  rm -r "$backup_dir"
fi
if [ -f "./backup.log" ]; then
    rm ./backup.log
    echo "previous backup.log file found. deleting..."
fi
backup_log="./backup.log"

mkdir -p "${cb_dir}"
mkdir -p "${ib_dir}"

timestamp() {
  date '+%a %d %b %Y %I:%M:%S %p %Z'
}

complete_backup() {
  local cb_file="cb$CB_COUNTER.tar"
  find $HOME -name "*.txt" -type f -exec tar -cvf "${cb_dir}/${cb_file}" {} +
  echo "$(timestamp) ${cb_file} was created" >> "${backup_log}"
  ((CB_COUNTER++))
}

incremental_backup() {
  local ib_file="ib$IB_COUNTER.tar"
  local ref_file="$1"
  find $HOME -name "*.txt" -type f -newer "${ref_file}" -exec tar -cvf "${ib_dir}/${ib_file}" {} +
  
  if [ -s "${ib_dir}/${ib_file}" ]; then
    echo "$(timestamp) ${ib_file} was created" >> "${backup_log}"
    echo "${ib_dir}/${ib_file}"
    ((IB_COUNTER++))
  else
    echo "$(timestamp) No changes-Incremental backup was not created" >> "${backup_log}"
    echo ""s
  fi
}

while true; do
  complete_backup
  sleep 2m

  last_complete_backup="${cb_dir}/$(ls -1t "${cb_dir}" | head -1)"
  incremental_backup "${last_complete_backup}"
  sleep 2m

  last_incremental_backup="${ib_dir}/$(ls -1t "${ib_dir}" | head -1)"
  incremental_backup "${last_incremental_backup}"
  
  sleep 2m

  last_incremental_backup="${ib_dir}/$(ls -1t "${ib_dir}" | head -1)"
  incremental_backup "${last_incremental_backup}"
  sleep 2m

done

