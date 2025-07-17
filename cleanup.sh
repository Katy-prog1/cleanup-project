#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
  echo "Please run as root"
  exit 2
fi

if [[ -t 0 ]]; then
    interactive=true
else
    interactive=false
fi

shopt -s globstar dotglob

directories=( '/tmp' '/var/tmp' '/var/log' )
bad_days=17
to_delete=()
mibibyte=$((2**20))
total_mibibytes=0
total_bytes=0

for dir in "${directories[@]}"; do
    for file in "$dir"/**; do
        [[ -f $file ]] || continue

        last_modification_seconds=$(stat --format=%Y "$file")
        last_modification_in_days=$((($(date +%s) - last_modification_seconds) / 86400))
        if (( last_modification_in_days >= bad_days)); then
            to_delete+=("$file")
            read -r -a size_in_bytes_a <<< "$(wc -c "$file")"
            size_in_bytes="${size_in_bytes_a[0]}"
            total_bytes=$(( total_bytes + size_in_bytes ))
        fi
    done
done

total_mibibytes=$((total_bytes / mibibyte ))
if $interactive && (( total_mibibytes >= 10 )); then

    read -rp "Found files total ${total_mibibytes}MiB. Are you shure you want to delete? [Y/N] " response
    response=${response:-N}

    if [[ ! $response =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
fi

for f in "${to_delete[@]}"; do
  rm -f "$f"
done

echo "Deleted ${#to_delete[@]} files size of all - ${total_mibibytes}MiB."