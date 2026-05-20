#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DIR="$HOME/.local/bin"
BIN_TARGET="$BIN_DIR/unreal-auto-open"
CONF_TARGET="$HOME/.config/ue-versions.conf"
DESKTOP_DIR="$HOME/.local/share/applications"
MIME_TARGET="$HOME/.local/share/mime/packages/unreal-uproject.xml"
ICON_MIME="$HOME/.local/share/icons/hicolor/256x256/mimetypes/application-x-uproject.png"

# Залежності
if ! command -v zenity &>/dev/null; then
    echo "Встановлення залежності: zenity"
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm zenity
    elif command -v apt &>/dev/null; then
        sudo apt install -y zenity
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y zenity
    else
        echo "! Не вдалось встановити zenity автоматично. Встановіть вручну."
        exit 1
    fi
fi

# Скрипт
mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/unreal-auto-open" "$BIN_TARGET"
chmod +x "$BIN_TARGET"
echo "✓ Скрипт встановлено: $BIN_TARGET"

# Конфіг
if [[ ! -f "$CONF_TARGET" ]]; then
    cp "$SCRIPT_DIR/ue-versions.conf" "$CONF_TARGET"
    echo "✓ Конфіг створено: $CONF_TARGET"
else
    echo "! Конфіг вже існує, не перезаписую: $CONF_TARGET"
fi

# Пошук іконки по директорії бінарника
find_icon_for_binary() {
    local binary="$1"
    local bin_dir
    bin_dir=$(dirname "$binary")
    for icon_name in UE4.png UnrealEngine.png; do
        local icon_path="$bin_dir/../../Source/Runtime/Launch/Resources/Linux/$icon_name"
        if [[ -f "$icon_path" ]]; then
            echo "$icon_path"
            return
        fi
    done
}

# Видалити старі некоректні .desktop файли UE
rm -f "$DESKTOP_DIR/ue4-27.desktop" 2>/dev/null && echo "✓ Видалено старий ue4-27.desktop" || true

mkdir -p "$DESKTOP_DIR"
mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
mkdir -p "$(dirname "$ICON_MIME")"

FIRST_ICON=""

# Для кожної версії з конфігу — окремий .desktop
while IFS= read -r line; do
    # Пропускаємо коментарі, порожні рядки і GUID записи
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    [[ "$line" =~ ^\{ ]] && continue

    version=$(echo "$line" | cut -d'=' -f1 | xargs)
    binary=$(echo "$line" | cut -d'=' -f2- | xargs)
    [[ -z "$version" || -z "$binary" ]] && continue

    # Безпечна назва файлу: "4.27" -> "4-27"
    safe_ver="${version//\./-}"
    desktop_file="$DESKTOP_DIR/unreal-engine-${safe_ver}.desktop"
    icon_id="unreal-engine-${safe_ver}"
    icon_dest="$HOME/.local/share/icons/hicolor/256x256/apps/${icon_id}.png"

    # Іконка
    icon_src=$(find_icon_for_binary "$binary")
    if [[ -n "$icon_src" ]]; then
        cp "$icon_src" "$icon_dest"
        [[ -z "$FIRST_ICON" ]] && FIRST_ICON="$icon_src"
    fi

    # .desktop для прямого запуску редактора
    cat > "$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=Unreal Engine ${version}
Comment=Unreal Engine ${version} Editor
Exec=${binary}
Icon=${icon_id}
Categories=Development;Game;
StartupNotify=true
EOF
    echo "✓ Unreal Engine ${version} → $(basename "$desktop_file")"

done < "$CONF_TARGET"

# Іконка для MIME (.uproject файлів) — беремо першу знайдену
if [[ -n "$FIRST_ICON" ]]; then
    cp "$FIRST_ICON" "$ICON_MIME"
fi

gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

# MIME тип для .uproject
mkdir -p "$(dirname "$MIME_TARGET")"
cat > "$MIME_TARGET" <<'EOF'
<?xml version="1.0"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-uproject">
    <comment>Unreal Engine Project</comment>
    <glob pattern="*.uproject" weight="100"/>
  </mime-type>
</mime-info>
EOF
update-mime-database "$HOME/.local/share/mime"
echo "✓ MIME тип зареєстровано: application/x-uproject"

# Іконка для unreal-auto-open.desktop — беремо від першої версії в конфігу
FIRST_VER=$(grep -v '^\s*#' "$CONF_TARGET" | grep -v '^\s*$' | grep -v '^\s*{' | head -1 | cut -d'=' -f1 | xargs | tr '.' '-')
AUTO_ICON="${FIRST_VER:+unreal-engine-${FIRST_VER}}"

# .desktop для відкриття .uproject (через скрипт що визначає версію)
cat > "$DESKTOP_DIR/unreal-auto-open.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Unreal Engine
Comment=Auto-open Unreal Engine project with correct version
Exec=$BIN_TARGET %F
Icon=$AUTO_ICON
Categories=Development;Game;
MimeType=application/x-uproject;
NoDisplay=true
EOF

update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

# Дефолтна програма для .uproject
xdg-mime default unreal-auto-open.desktop application/x-uproject
echo "✓ Встановлено як дефолтну для .uproject"

echo ""
echo "Готово. Відредагуй конфіг і додай свої версії UE:"
echo "  $CONF_TARGET"
