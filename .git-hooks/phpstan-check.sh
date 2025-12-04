#!/bin/bash
set -e

# commit или push
MODE="$1"

# Определяем корень проекта
PROJECT_ROOT=$(git rev-parse --show-toplevel)

if [ "$MODE" = "commit" ]; then
  FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.php$' || true)
elif [ "$MODE" = "push" ]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  FILES=$(git diff --name-only origin/$BRANCH --diff-filter=ACM | grep '\.php$' || true)
else
  echo "phpstan-check.sh: неизвестный режим: $MODE"
  exit 1
fi

if [ -z "$FILES" ]; then
  echo "✅ [PHPStan] Нет PHP-файлов для проверки."
  exit 0
fi

echo "🔍 [PHPStan] Анализ файлов:"
echo "$FILES"

# Запуск phpstan на списке файлов
vendor/bin/phpstan analyse $FILES --error-format=table -c "$PROJECT_ROOT/phpstan.neon"
RC=$?

if [ $RC -ne 0 ]; then
  echo "❌ [PHPStan] Обнаружены ошибки. Исправьте их."
  exit $RC
fi

echo "✅ [PHPStan] OK"
exit 0
