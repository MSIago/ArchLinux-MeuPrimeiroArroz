#!/bin/bash

ACTIVE_OPACITY=1.0
INACTIVE_OPACITY=0.6

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
DEBOUNCE_FILE="/tmp/opacity-last-event"
DEBOUNCE_MS=150

update_opacity() {
    sleep 0.05

    local mouse_mon
    mouse_mon=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name')

    local active_addr
    active_addr=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')

    local monitors_json
    monitors_json=$(hyprctl monitors -j)

    hyprctl clients -j | jq -c '.[]' | while IFS= read -r client; do
        local addr mon_id mon_name opacity
        addr=$(echo "$client" | jq -r '.address')
        mon_id=$(echo "$client" | jq -r '.monitor')
        mon_name=$(echo "$monitors_json" | jq -r --argjson id "$mon_id" '.[] | select(.id==$id) | .name')

        if [ "$mon_name" != "$mouse_mon" ]; then
            opacity=$ACTIVE_OPACITY
        elif [ "$addr" == "$active_addr" ]; then
            opacity=$ACTIVE_OPACITY
        else
            opacity=$INACTIVE_OPACITY
        fi

        hyprctl dispatch "hl.dsp.window.set_prop({ prop = \"opacity\", value = \"$opacity\", window = \"address:$addr\" })" >/dev/null
        hyprctl dispatch "hl.dsp.window.set_prop({ prop = \"opacity_inactive\", value = \"$opacity\", window = \"address:$addr\" })" >/dev/null
    done
}

# aplica uma vez ao iniciar
update_opacity

# thread que só roda update_opacity quando os eventos "acalmarem"
(
    last_applied=""
    while true; do
        sleep 0.05
        [ -f "$DEBOUNCE_FILE" ] || continue
        ts=$(cat "$DEBOUNCE_FILE")
        now=$(date +%s%N)
        diff_ms=$(( (now - ts) / 1000000 ))
        if [ "$diff_ms" -ge "$DEBOUNCE_MS" ] && [ "$ts" != "$last_applied" ]; then
            last_applied="$ts"
            update_opacity
        fi
    done
) &

# escuta os eventos do Hyprland e só marca que algo mudou (não aplica na hora)
socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do
    case "$line" in
        focusedmon\>\>*|activewindow\>\>*|openwindow\>\>*|closewindow\>\>*|movewindow\>\>*)
            date +%s%N >"$DEBOUNCE_FILE"
            ;;
    esac
done
