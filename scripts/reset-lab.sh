#!/bin/bash
# Сброс лабы в исходное состояние

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPOSE_FILE="$REPO_ROOT/lab-infra/docker-compose.lab.yml"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
elif [[ $# -gt 0 ]]; then
  echo "Неизвестный аргумент: $1"
  echo "Использование: $0 [--dry-run]"
  exit 1
fi

run_or_print() {
  if $DRY_RUN; then
    echo "[DRY-RUN] $*"
  else
    "$@"
  fi
}

collect_matches() {
  local base_dir="$1"
  local filename="$2"
  shift 2

  if [[ ! -d "$base_dir" ]]; then
    return
  fi

  find "$base_dir" -type f -name "$filename" "$@" -not -path "*/solutions/*"
}

collect_matches_dir() {
  local base_dir="$1"
  local dir_name="$2"
  shift 2

  if [[ ! -d "$base_dir" ]]; then
    return
  fi

  find "$base_dir" -type d -name "$dir_name" "$@" -not -path "*/solutions/*"
}

echo "Останавливаем контейнеры..."
if [[ -f "$COMPOSE_FILE" ]]; then
  run_or_print docker compose -f "$COMPOSE_FILE" down -v
else
  echo "Compose-файл не найден, пропускаем остановку контейнеров: $COMPOSE_FILE"
fi

TARGET_STAGE_DIR="$REPO_ROOT/stage-0"

declare -a candidate_paths=()
while IFS= read -r path; do
  candidate_paths+=("$path")
done < <(
  {
    collect_matches "$TARGET_STAGE_DIR" "gost-mapping.md" -path "*/0.1-*/*"
    collect_matches "$TARGET_STAGE_DIR" "stride-analysis.md" -path "*/0.2-*/*"
    collect_matches "$TARGET_STAGE_DIR" "security-requirements.md" -path "*/0.3-*/*"
    collect_matches "$TARGET_STAGE_DIR" "threat-model.py" -path "*/0.2-*/*"
    collect_matches_dir "$TARGET_STAGE_DIR" "pytm-report" -path "*/0.2-*/*"
  } | sort -u
)

if [[ ${#candidate_paths[@]} -eq 0 ]]; then
  echo "Артефакты для удаления не найдены."
  echo "Лаба сброшена. Начинайте с stage-0/README.md"
  exit 0
fi

echo "Найдены артефакты для удаления (${#candidate_paths[@]}):"
for path in "${candidate_paths[@]}"; do
  rel_path="${path#"$REPO_ROOT"/}"
  echo " - $rel_path"
done

if $DRY_RUN; then
  echo "[DRY-RUN] Режим предпросмотра: удаление не выполнялось."
  exit 0
fi

read -r -p "Подтвердите удаление перечисленных артефактов (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
  echo "Отменено пользователем."
  exit 1
fi

declare -a deleted_paths=()
for path in "${candidate_paths[@]}"; do
  if [[ -d "$path" ]]; then
    rm -rf "$path"
    deleted_paths+=("$path")
  elif [[ -f "$path" ]]; then
    rm -f "$path"
    deleted_paths+=("$path")
  fi
done

echo "Удалено файлов/директорий: ${#deleted_paths[@]}"
for path in "${deleted_paths[@]}"; do
  rel_path="${path#"$REPO_ROOT"/}"
  echo " - $rel_path"
done

if [[ -d "$REPO_ROOT/.git" && ${#deleted_paths[@]} -gt 0 ]]; then
  printf -v restore_cmd 'git -C %q restore --' "$REPO_ROOT"
  for path in "${deleted_paths[@]}"; do
    rel_path="${path#"$REPO_ROOT"/}"
    printf -v quoted ' %q' "$rel_path"
    restore_cmd+="$quoted"
  done
  echo "Для восстановления через git выполните:"
  echo "  $restore_cmd"
fi

echo "Лаба сброшена. Начинайте с stage-0/README.md"
