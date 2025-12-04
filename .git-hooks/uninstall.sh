#!/bin/bash

echo "🧹 Отключение Git hooks..."

HOOKS_DIR=".git/hooks"

declare -a HOOKS=("pre-commit" "pre-push")

for HOOK in "${HOOKS[@]}"; do
    rm -f "$HOOKS_DIR/$HOOK"
    echo "✘ Hook $HOOK отключён"
done

echo "👌 Git hooks выключены!"
