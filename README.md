# Hyprland Dotfiles (Arch Linux)

Configuração pessoal do Hyprland para Arch Linux: config em Lua, `hyprpaper`, `waybar`, `hyprlauncher`, e dois scripts customizados feitos para um setup com **dois monitores** (laptop + monitor externo).

## O que tem aqui

- **`opacity-per-monitor.sh`** — mantém opacidade cheia em todas as janelas, exceto a janela "inativa" do monitor onde o mouse está no momento, que fica semitransparente. Janelas do outro monitor sempre ficam opacas, não importa o foco.
- **`wallpaper-changer.sh`** — troca o papel de parede periodicamente, aplicando a mesma troca em vários monitores ao mesmo tempo.
- **`hyprland.lua`** — config principal: monitores, binds, regras de janela, e as workspaces 1–5 fixas no monitor externo e 6–10 fixas no laptop.

## Estrutura do repositório

```
.
├── install.sh
├── hypr/
│   ├── hyprland.lua
│   └── scripts/
│       ├── wallpaper-changer.sh
│       └── opacity-per-monitor.sh
├── waybar/
│   ├── config.jsonc
│   └── style.css
└── applications/
    └── go-live.desktop
```

## Pré-requisitos

- Arch Linux (ou derivada) com `pacman`
- Permissão de `sudo`

## Instalação

```bash
git clone https://github.com/SEU_USUARIO/hyprland-dotfiles.git
cd hyprland-dotfiles
chmod +x install.sh
./install.sh
```

O `install.sh` faz, nessa ordem:

1. Instala todos os pacotes necessários via `pacman`.
2. Copia `hypr/` para `~/.config/hypr` e `waybar/` para `~/.config/waybar` (pergunta antes de sobrescrever se a pasta já existir e não estiver vazia).
3. Dá permissão de execução aos scripts em `hypr/scripts/`.
4. Instala o atalho `applications/go-live.desktop` em `~/.local/share/applications`, se o arquivo existir.

## Pacotes instalados

| Pacote | Uso |
|---|---|
| `hyprland` | compositor |
| `hyprpaper` | wallpaper |
| `waybar` | barra |
| `hyprlauncher` | lançador de apps (`SUPER + R`) |
| `kitty` | terminal |
| `dolphin` | gerenciador de arquivos |
| `grim` + `slurp` | screenshots |
| `wl-clipboard` | clipboard (`wl-copy`) |
| `brightnessctl` | brilho da tela |
| `playerctl` | controle de mídia |
| `jq` + `socat` | usados pelo `opacity-per-monitor.sh` |
| `desktop-file-utils` | `update-desktop-database`, pra atalhos `.desktop` |

## ⚠️ Antes de usar em outra máquina

Os scripts e o `hyprland.lua` têm alguns valores **específicos da minha máquina**, que você precisa ajustar:

- **Nomes de monitor**: `eDP-1` e `HDMI-A-1`. Rode `hyprctl monitors` na sua máquina e ajuste `hl.monitor(...)` em `hypr/hyprland.lua`, além da flag `-m` no autostart do `wallpaper-changer.sh`.
- **Caminhos com `/home/arch/...`**: tanto os scripts quanto o `hyprland.lua` usam o caminho absoluto `/home/arch/`. Se seu usuário tiver outro nome, troque todas as ocorrências (`grep -rl "/home/arch" .` pra encontrar onde).
- **Pasta de wallpapers**: `/home/arch/Imagens/Wallpapers/motoko/` — aponte pra sua própria pasta de imagens.

## Uso dos scripts

### `wallpaper-changer.sh`
```bash
wallpaper-changer.sh -p /caminho/das/imagens -i 60 -m eDP-1,HDMI-A-1
```
`-m` aceita um ou mais monitores separados por vírgula; a troca acontece em todos ao mesmo tempo, a cada `-i` segundos.

### `opacity-per-monitor.sh`
Sem parâmetros — já é chamado no autostart do `hyprland.lua`. Os valores de opacidade (`ACTIVE_OPACITY` / `INACTIVE_OPACITY`) ficam configuráveis no topo do próprio arquivo.

## Licença

Use como quiser.
