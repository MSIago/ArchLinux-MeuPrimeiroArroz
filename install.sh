#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "==> Instalando pacotes via pacman..."
sudo pacman -S --needed hyprland hyprpaper waybar hyprlauncher kitty dolphin \
    grim slurp wl-clipboard brightnessctl playerctl jq socat desktop-file-utils

copy_dir() {
    src=$1
    dest=$2

    if [ ! -d "$src" ]; then
        return
    fi

    mkdir -p "$dest"

    if [ -n "$(ls -A "$dest" 2>/dev/null)" ]; then
        read -r -p "A pasta $dest já existe e não está vazia. Sobrescrever? [y/N] " answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            echo "Pulando $dest"
            return
        fi
    fi

    cp -rv "$src/." "$dest/"
}

echo "==> Copiando configuração do Hyprland..."
copy_dir "$REPO_DIR/hypr" "$CONFIG_DIR/hypr"

echo "==> Copiando configuração do Waybar..."
copy_dir "$REPO_DIR/waybar" "$CONFIG_DIR/waybar"

echo "==> Dando permissão de execução aos scripts..."
chmod +x "$CONFIG_DIR/hypr/scripts/"*.sh 2>/dev/null || true

if [ -f "$REPO_DIR/applications/go-live.desktop" ]; then
    echo "==> Instalando atalho do Go-Live..."
    mkdir -p "$HOME/.local/share/applications"
    cp "$REPO_DIR/applications/go-live.desktop" "$HOME/.local/share/applications/"
    chmod +x "$HOME/.local/share/applications/go-live.desktop"
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

echo
echo "==> Concluído!"
echo "Ajuste os nomes dos monitores em ~/.config/hypr/hyprland.lua (hyprctl monitors)"
echo "antes de reiniciar o Hyprland, caso seu hardware seja diferente."
