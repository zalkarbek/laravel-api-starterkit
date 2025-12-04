#!/bin/bash
set -e

MODE="$1"  # commit или push

# Определяем корень проекта
PROJECT_ROOT=$(git rev-parse --show-toplevel)

# Собираем файлы для проверки
if [ "$MODE" = "commit" ]; then
  FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.php$' || true)
elif [ "$MODE" = "push" ]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  FILES=$(git diff --name-only origin/$BRANCH --diff-filter=ACM | grep '\.php$' || true)
else
  echo "legacy-check.sh: неизвестный режим: $MODE"
  exit 1
fi

# Если файлов нет — выходим
if [ -z "$FILES" ]; then
  echo "✅ [Legacy] Нет PHP-файлов для проверки."
  exit 0
fi

# Создаём кеш для хранения количества ошибок
mkdir -p "$PROJECT_ROOT/.phpstan-cache"
echo "🔧 [Legacy] Проверка уменьшения количества ошибок (не блокирует)."

for FILE in $FILES; do
  KEY=$(echo "$FILE" | tr '/' '_')
  PREV_FILE="$PROJECT_ROOT/.phpstan-cache/${KEY}.count"

  # Получаем текущее количество ошибок для файла
  CURRENT=$(vendor/bin/phpstan analyse "$FILE" --error-format=raw --baseline="$PROJECT_ROOT/phpstan-baseline.neon" 2>/dev/null | wc -l)
  PREVIOUS=$(cat "$PREV_FILE" 2>/dev/null || echo $CURRENT)

  if [ "$CURRENT" -lt "$PREVIOUS" ]; then
    echo "✅ $FILE: ошибок стало меньше ($PREVIOUS -> $CURRENT)"
  elif [ "$CURRENT" -gt "$PREVIOUS" ]; then
    echo "⚠ $FILE: ошибок стало больше ($PREVIOUS -> $CURRENT)"
  else
    echo "ℹ $FILE: без изменений ($CURRENT)"
  fi

  # Сохраняем текущее количество ошибок
  echo "$CURRENT" > "$PREV_FILE"
done

echo "✅ [Legacy] Проверка завершена."
exit 0
