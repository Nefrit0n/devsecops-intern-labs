#!/bin/bash
# Быстрая установка базовых инструментов с preflight-проверками

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PYTM_VERSION="1.3.1"
BANDIT_VERSION="1.7.10"
SEMGREP_VERSION="1.72.0"
GITLEAKS_VERSION="8.24.2"

SUMMARY_LINES=()

ok() { SUMMARY_LINES+=("${GREEN}✓${NC} $1"); }
warn() { SUMMARY_LINES+=("${YELLOW}○${NC} $1"); }
err() { SUMMARY_LINES+=("${RED}✗${NC} $1"); }

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

cmd_version_line() {
    "$1" --version 2>/dev/null | head -1
}

preflight() {
    echo "==> Preflight-checks"

    case "$(uname -s)" in
        Linux|Darwin)
            echo -e "  ${GREEN}✓${NC} Поддерживаемая ОС: $(uname -s)"
            ;;
        *)
            echo -e "  ${RED}✗${NC} Неподдерживаемая ОС: $(uname -s). Поддерживаются Linux/macOS."
            exit 1
            ;;
    esac

    if ! have_cmd curl; then
        echo -e "  ${RED}✗${NC} Не найден curl (обязателен для установки gitleaks)."
        exit 1
    fi
    echo -e "  ${GREEN}✓${NC} curl найден"

    if have_cmd python3; then
        PYTHON_BIN="python3"
    elif have_cmd python; then
        PYTHON_BIN="python"
    else
        echo -e "  ${RED}✗${NC} Не найден Python (python3/python)."
        exit 1
    fi

    if "$PYTHON_BIN" -m pip --version >/dev/null 2>&1; then
        PIP_CMD=("$PYTHON_BIN" -m pip)
        echo -e "  ${GREEN}✓${NC} pip доступен через: ${PYTHON_BIN} -m pip"
    else
        echo -e "  ${RED}✗${NC} pip недоступен для ${PYTHON_BIN}."
        exit 1
    fi

    if [[ "$(uname -s)" == "Linux" ]]; then
        if have_cmd sudo; then
            echo -e "  ${GREEN}✓${NC} sudo найден"
        else
            echo -e "  ${YELLOW}○${NC} sudo не найден — будет использован user-local путь"
        fi
    fi
}

resolve_install_path() {
    LOCAL_BIN_DEFAULT="${HOME}/.local/bin"
    SYSTEM_BIN_DEFAULT="/usr/local/bin"

    if [[ -n "${INSTALL_DIR:-}" ]]; then
        TARGET_BIN_DIR="$INSTALL_DIR"
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        TARGET_BIN_DIR="$LOCAL_BIN_DEFAULT"
    elif [[ -w "$SYSTEM_BIN_DEFAULT" ]]; then
        TARGET_BIN_DIR="$SYSTEM_BIN_DEFAULT"
    elif have_cmd sudo; then
        TARGET_BIN_DIR="$SYSTEM_BIN_DEFAULT"
    else
        TARGET_BIN_DIR="$LOCAL_BIN_DEFAULT"
    fi

    mkdir -p "$TARGET_BIN_DIR" 2>/dev/null || {
        echo -e "  ${RED}✗${NC} Не удалось создать директорию: $TARGET_BIN_DIR"
        exit 1
    }

    if [[ -w "$TARGET_BIN_DIR" ]]; then
        INSTALL_WITH_SUDO="false"
    elif have_cmd sudo; then
        INSTALL_WITH_SUDO="true"
    else
        echo -e "  ${RED}✗${NC} Нет прав на запись в $TARGET_BIN_DIR и sudo недоступен."
        exit 1
    fi

    echo "  Выбран путь установки бинарников: $TARGET_BIN_DIR"
    if [[ "$INSTALL_WITH_SUDO" == "true" ]]; then
        echo "  Запись будет выполнена через sudo"
    fi
}

show_existing_versions() {
    echo ""
    echo "==> Обнаруженные версии до установки"

    if have_cmd semgrep; then echo "  semgrep: $(cmd_version_line semgrep)"; else echo "  semgrep: не найден"; fi
    if have_cmd bandit; then echo "  bandit: $(cmd_version_line bandit)"; else echo "  bandit: не найден"; fi
    if have_cmd gitleaks; then echo "  gitleaks: $(cmd_version_line gitleaks)"; else echo "  gitleaks: не найден"; fi

    "$PYTHON_BIN" - <<PY
import importlib
for name in ("pytm",):
    try:
        m = importlib.import_module(name)
        version = getattr(m, "__version__", "installed")
        print(f"  {name}: {version}")
    except Exception:
        print(f"  {name}: не найден")
PY
}

install_python_tools() {
    echo ""
    echo "==> Установка Python-инструментов (фиксированные версии)"
    "${PIP_CMD[@]}" install --upgrade \
        "pytm==${PYTM_VERSION}" \
        "bandit==${BANDIT_VERSION}" \
        "semgrep==${SEMGREP_VERSION}"
}

install_gitleaks() {
    echo ""
    echo "==> Установка gitleaks v${GITLEAKS_VERSION}"

    if [[ "$(uname -s)" == "Linux" ]]; then
        tmp_file="$(mktemp)"
        curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" -o "$tmp_file" || {
            rm -f "$tmp_file"
            echo -e "  ${RED}✗${NC} Не удалось скачать gitleaks v${GITLEAKS_VERSION}"
            return 1
        }

        tar -xzf "$tmp_file" -C /tmp gitleaks || {
            rm -f "$tmp_file"
            echo -e "  ${RED}✗${NC} Не удалось распаковать gitleaks"
            return 1
        }
        rm -f "$tmp_file"

        if [[ "$INSTALL_WITH_SUDO" == "true" ]]; then
            sudo install -m 0755 /tmp/gitleaks "$TARGET_BIN_DIR/gitleaks"
        else
            install -m 0755 /tmp/gitleaks "$TARGET_BIN_DIR/gitleaks"
        fi
        rm -f /tmp/gitleaks
    else
        echo -e "  ${YELLOW}○${NC} Для macOS рекомендуется: brew install gitleaks"
        if have_cmd brew; then
            brew install gitleaks || brew upgrade gitleaks
        else
            return 1
        fi
    fi
}

verify_install() {
    echo ""
    echo "==> Проверка установки"

    if "$PYTHON_BIN" -c "import pytm" >/dev/null 2>&1; then
        ok "pytm==${PYTM_VERSION} (Python module)"
    else
        err "pytm (не импортируется)"
    fi

    if have_cmd bandit; then
        ok "bandit: $(cmd_version_line bandit)"
    else
        err "bandit не найден"
    fi

    if have_cmd semgrep; then
        ok "semgrep: $(cmd_version_line semgrep)"
    else
        err "semgrep не найден"
    fi

    if have_cmd gitleaks; then
        ok "gitleaks: $(cmd_version_line gitleaks)"
    elif [[ -x "$TARGET_BIN_DIR/gitleaks" ]]; then
        ok "gitleaks установлен в $TARGET_BIN_DIR/gitleaks"
    else
        err "gitleaks не найден"
    fi
}

show_post_install_summary() {
    echo ""
    echo "========================================"
    echo "  Post-install summary"
    echo "========================================"
    for line in "${SUMMARY_LINES[@]}"; do
        echo -e "  $line"
    done
    echo ""

    if [[ ":$PATH:" != *":$TARGET_BIN_DIR:"* ]]; then
        echo -e "  ${YELLOW}○${NC} $TARGET_BIN_DIR не найден в PATH"
        echo "  Добавьте в ~/.bashrc или ~/.zshrc:"
        echo "    export PATH=\"$TARGET_BIN_DIR:\$PATH\""
        echo "  Затем примените: source ~/.bashrc (или source ~/.zshrc)"
    fi

    echo ""
    echo "Готово! Запустите ./scripts/check-tools.sh для расширенной проверки."
}

preflight
resolve_install_path
show_existing_versions
install_python_tools
install_gitleaks || warn "gitleaks: установка завершилась с предупреждением"
verify_install
show_post_install_summary
