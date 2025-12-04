#!/bin/bash

echo "🔗 Установка Git hooks..."

HOOKS_DIR=".git/hooks"
CUSTOM_DIR=".git-hooks"

declare -a HOOKS=("pre-commit" "pre-push")

# Создаем симлинки
for HOOK in "${HOOKS[@]}"; do
    rm -f "$HOOKS_DIR/$HOOK"
    ln -s "../../$CUSTOM_DIR/$HOOK" "$HOOKS_DIR/$HOOK"
    chmod +x "$CUSTOM_DIR/$HOOK"
    echo "✔ Hook $HOOK активирован"
done

echo "🎉 Git hooks включены!"
