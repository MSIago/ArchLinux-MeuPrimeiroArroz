#!/bin/bash

print_help() {
    echo "Usage: wallpaper-changer.sh [-p PATH] [-i INTERVAL] [-m MONITOR1,MONITOR2] [-h|--help]"
    echo
    echo "Options:"
    echo -e "  -i, --interval INTERVAL\tTime interval (in seconds) between wallpaper changes"
    echo -e "  -p, --path PATH\tpath to load wallpapers from. Default value is ~/Pictures/Wallpapers. Does not recursively load wallpapers"
    echo -e "  -m, --monitor MONITOR_NAME \t monitor(s) for which the wallpapers must be applied, separated by comma (e.g. eDP-1,HDMI-A-1). Use hyprctl monitors to see the list of monitors."
    echo "  -h, --help               Print this help message and exit"
}

preload_wallpapers() {
    wallpaper_dir=$1
    wallpapers=$(find "$wallpaper_dir" -type f)
    wallpapers_string=""
    OLDIFS=$IFS
    IFS=$'\n'
    for wallpaper in $wallpapers; do
        wallpapers_string+="preload = $wallpaper\n"
    done
    printf '%b' "$wallpapers_string" >/home/arch/.config/hypr/hyprpaper.conf
    echo "splash = false" >>/home/arch/.config/hypr/hyprpaper.conf
    IFS=$OLDIFS
}

# set the path to the wallpaper directory
wallpaper_dir="/home/arch/Imagens/Wallpapers/motoko/"

# parse the command line arguments
interval=300
while getopts ":hi:p:m:-:" opt; do
    case $opt in
    -)
        case "${OPTARG}" in
        interval)
            interval=$OPTIND
            OPTIND=$((OPTIND + 1))
            ;;
        help)
            print_help
            exit 0
            ;;
        path)
            wallpaper_dir=$OPTIND
            OPTIND=$((OPTIND + 1))
            ;;
        esac
        ;;
    h)
        print_help
        exit 0
        ;;
    i)
        interval=$OPTARG
        ;;
    p)
        wallpaper_dir=$OPTARG
        ;;
    m)
        monitors=$OPTARG
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
done
if [ -z "$monitors" ]; then
    echo "Error: -m/--monitors option is required" >&2
    exit 1
fi
preload_wallpapers "$wallpaper_dir"
readarray -d '' wallpapers < <(find "$wallpaper_dir" -type f -print0)
killall hyprpaper
hyprpaper >/dev/null 2>&1 &
disown

idx=0
n=${#wallpapers[@]}
while true; do
    sleep "$interval"
    current_wallpaper=${wallpapers[$idx]}
    IFS=',' read -ra monitor_array <<< "$monitors"
    for mon in "${monitor_array[@]}"; do
        hyprctl hyprpaper wallpaper "$mon,$current_wallpaper"
    done
    idx=$(((idx + 1) % n))
done
