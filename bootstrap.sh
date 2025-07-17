#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
  echo "Please run as root"
  exit 2
fi

for script in menu.sh cleanup.sh; do
  cp -f "./$script" "/usr/local/bin/$script"
  chmod +x "/usr/local/bin/$script"
done

# create cron jobs
(
# print existing crontab
crontab -l 2>/dev/null
echo "0 12 5 * * /usr/local/bin/cleanup.sh"
) | crontab -