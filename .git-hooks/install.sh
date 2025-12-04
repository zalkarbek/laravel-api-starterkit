#!/bin/bash
set -e

echo "🔗 Установка Git hooks..."

HOOKS_DIR=".git/hooks"
CUSTOM_DIR=".git-hooks"

# Проверяем, что папка .git/hooks существует
if [ ! -d "$HOOKS_DIR" ]; then
    echo "📌 Папка $HOOKS_DIR не найдена, создаём..."
    mkdir -p "$HOOKS_DIR"
fi

# Список хуков для подключения
declare -a HOOKS=("pre-commit" "pre-push")

# Делаем все скрипты исполняемыми
echo "🔧 Устанавливаем права на исполнение для всех хуков..."
chmod +x "$CUSTOM_DIR"/*.sh
chmod +x "$CUSTOM_DIR"/pre-commit "$CUSTOM_DIR"/pre-push

# Создаём симлинки в .git/hooks
for HOOK in "${HOOKS[@]}"; do
    # Удаляем старый файл/симлинк
    rm -f "$HOOKS_DIR/$HOOK"
    # Создаём симлинк на реальный скрипт
    ln -s "../../$CUSTOM_DIR/$HOOK" "$HOOKS_DIR/$HOOK"
    echo "✔ Hook $HOOK активирован"
done

echo "🎉 Git hooks включены!"
