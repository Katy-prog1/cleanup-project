#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
  echo "Please run as root"
  exit 2
fi


function get_process_count () {
    n=$(ps auxh | wc -l)
    n=$((n-2))
    echo "Current total number of running processes is: $n"
}


echo '------Menu-----'
PS3='~Select an option: '
options=('Show current system metrics' 'Run cleanup' 'Exit')

select option in "${options[@]}"; do
    case $option in
        "${options[0]}")
        get_process_count
        ;;
        "${options[1]}")
        /usr/local/bin/cleanup.sh
        ;;
        "${options[2]}")
        echo "You shure you want to exit? [Y/N]" shure
        shure=${shure:-N}
        if [[ $shure =~ ^[Yy] ]]; then
            exit 0
        else
            echo "exit canseled."
        fi
        ;;
        *)
        echo "Invalid input. Choose 1, 2 or 3"
    esac
done