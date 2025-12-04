#!/bin/bash
set -e

# commit или push
MODE="$1"

# Определяем корень проекта
PROJECT_ROOT=$(git rev-parse --show-toplevel)

# путь к конфигу Pint
PINT_CONFIG="$PROJECT_ROOT/pint.json"

if [ "$MODE" = "commit" ]; then
  FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.php$' || true)
elif [ "$MODE" = "push" ]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  FILES=$(git diff --name-only origin/$BRANCH --diff-filter=ACM | grep '\.php$' || true)
else
  echo "pint-check.sh: неизвестный режим: $MODE"
  exit 1
fi

if [ -z "$FILES" ]; then
  echo "✅ [Pint] Нет PHP-файлов для проверки."
  exit 0
fi

echo "🔍 [Pint] Тест форматирования..."
vendor/bin/pint --config=$PINT_CONFIG --test $FILES
RC=$?

if [ $RC -ne 0 ]; then
  echo "❌ [Pint] Нарушения стиля найдены — выполняю автоисправление..."
  vendor/bin/pint --config=$PINT_CONFIG $FILES

  # добавить исправленные файлы в staged (если есть)
  echo "$FILES" | xargs -r git add

  echo "✅ [Pint] Форматирование применено. Пожалуйста, перезапустите commit/push."
  exit 1  # вернём ошибку, чтобы пользователь повторно сделал commit после автоисправления
fi

echo "✅ [Pint] OK"
exit 0
