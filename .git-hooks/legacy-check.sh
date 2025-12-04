#!/bin/bash
set -e

MODE="$1"  # commit или push

if [ "$MODE" = "commit" ]; then
  FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.php$' || true)
elif [ "$MODE" = "push" ]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  FILES=$(git diff --name-only origin/$BRANCH --diff-filter=ACM | grep '\.php$' || true)
else
  echo "legacy-check.sh: неизвестный режим: $MODE"
  exit 1
fi

if [ -z "$FILES" ]; then
  echo "✅ [Legacy] Нет PHP-файлов для проверки."
  exit 0
fi

mkdir -p .phpstan-cache
echo "🔧 [Legacy] Проверка уменьшения количества ошибок (не блокирует)."

for FILE in $FILES; do
  KEY=$(echo "$FILE" | tr '/' '_')
  PREV_FILE=".phpstan-cache/${KEY}.count"

  # Получаем кол-во ошибок для конкретного файла (raw вывод => подсчёт строк)
  CURRENT=$(vendor/bin/phpstan analyse $FILE --error-format=raw --baseline=phpstan-baseline.neon 2>/dev/null | wc -l)
  PREVIOUS=$(cat "$PREV_FILE" 2>/dev/null || echo $CURRENT)

  if [ "$CURRENT" -lt "$PREVIOUS" ]; then
    echo "✅ $FILE: ошибок стало меньше ($PREVIOUS -> $CURRENT)"
  elif [ "$CURRENT" -gt "$PREVIOUS" ]; then
    echo "⚠ $FILE: ошибок стало больше ($PREVIOUS -> $CURRENT)"
  else
    echo "ℹ $FILE: без изменений ($CURRENT)"
  fi

  echo "$CURRENT" > "$PREV_FILE"
done

echo "✅ [Legacy] Проверка завершена."
exit 0
