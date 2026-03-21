# 🎬 Демо-записи и скринкасты

Руководство по записи и каталог демонстраций для каждого этапа курса.

---

## Инструменты для записи

### Asciinema — запись терминала (основной формат)

Идеален для CLI-инструментов (90% нашего курса). Текстовый формат: студент может поставить на паузу и скопировать команду прямо из «видео».

```bash
# Установка
pip install asciinema

# Запись
asciinema rec my-demo.cast

# ... делаете демо ...
# Ctrl+D — стоп

# Загрузка (получите ссылку)
asciinema upload my-demo.cast

# Или локальное воспроизведение
asciinema play my-demo.cast
```

**Советы по записи:**
- Очистите терминал перед записью: `clear`
- Увеличьте шрифт: `export PS1="\n\$ "` (короткий prompt)
- Пауза перед важными моментами — студент должен успеть прочитать
- Комментируйте голосом или `echo "# Сейчас запустим Semgrep..."` перед командой
- Идеальная длина: 1–3 минуты. Если дольше — разбейте на части
- Размер окна: 120×30 (стандартный wide terminal)

```bash
# Запись с фиксированным размером
asciinema rec --cols 120 --rows 30 my-demo.cast
```

### GIF — для UI-инструментов

Для инструментов с графическим интерфейсом: ZAP, DefectDojo, Dependency-Track, draw.io.

```bash
# Linux — Peek (GUI recorder → GIF)
sudo apt install peek

# macOS — Kap (бесплатный)
brew install --cask kap

# Конвертация видео → GIF (из любой записи экрана)
# gifski даёт лучшее качество при малом размере
brew install gifski        # macOS
cargo install gifski       # любая ОС

ffmpeg -i recording.mp4 -vf "fps=10,scale=800:-1" frames/%04d.png
gifski --fps 10 --width 800 -o demo.gif frames/*.png
```

**Советы по GIF:**
- Ширина: 800px (читаемо, не огромный файл)
- FPS: 10 (достаточно для UI, экономит размер)
- Длина: 5–20 секунд. Если дольше — лучше asciinema или видео
- Выделяйте курсором/кликом то, на что нужно обратить внимание
- Размер файла: старайтесь ≤5MB (GitHub ограничение без LFS)

### Скриншоты — для статических UI

Иногда GIF избыточен — достаточно скриншота с аннотацией.

```bash
# Скриншот + аннотация (стрелки, подписи)
# Инструменты: Flameshot (Linux), CleanShot X (macOS), ShareX (Windows)

# Flameshot
sudo apt install flameshot
flameshot gui  # → рисуете стрелки, подписи → сохраняете
```

**Формат:** PNG, ширина 800–1200px, подписи на русском.

---

## Как встраивать в markdown

### Asciinema (ссылка)
```markdown
> 🎬 **Демо:** [Запуск Semgrep на Juice Shop](https://asciinema.org/a/xxxxx)
```

### Asciinema (embed — если используете MkDocs/GitHub Pages)
```html
<script src="https://asciinema.org/a/xxxxx.js" id="asciicast-xxxxx" async></script>
```

### GIF (встроенный)
```markdown
> 🎬 **Демо:**
>
> ![ZAP finding в интерфейсе](../../assets/demos/stage-3/zap-finding.gif)
```

### Скриншот с подписью
```markdown
> 📸 **Скриншот:** DefectDojo dashboard после импорта всех отчётов
>
> ![DefectDojo dashboard](../../assets/demos/stage-5/defectdojo-dashboard.png)
```

---

## Каталог демо по этапам

### Этап 0 · Фундамент

| ID | Тип | Файл | Что показать | Время | Куда встроить |
|----|-----|------|-------------|-------|---------------|
| 0-1 | 📸 screenshot | `stage-0/dfd-example.png` | DFD Level 1 в draw.io: компоненты Juice Shop, trust boundaries, потоки данных | — | 0.2-threat-modeling/README.md |
| 0-2 | 🖥️ asciinema | `stage-0/pytm-run.cast` | `python threat-model.py --dfd \| dot -Tpng` → генерация DFD и отчёта из кода | 1.5 мин | 0.2-threat-modeling/tasks.md |

---

### Этап 1 · Код под микроскопом

| ID | Тип | Файл | Что показать | Время | Куда встроить |
|----|-----|------|-------------|-------|---------------|
| 1-1 | 🖥️ asciinema | `stage-1/semgrep-first-run.cast` | `semgrep --config auto .` → поток findings, разноцветный output, итоговая статистика | 2 мин | sast/tasks.md (задание 1) |
| 1-2 | 🖥️ asciinema | `stage-1/semgrep-custom-rule.cast` | Написание YAML-правила → запуск → finding по кастомному правилу | 2 мин | sast/tasks.md (задание 1, шаг 3) |
| 1-3 | 🖥️ asciinema | `stage-1/gitleaks-precommit.cast` | `echo 'AWS_KEY=AKIA...' > test.txt && git commit` → **BLOCKED!** Драматический момент. Затем `rm test.txt` | 1 мин | secrets/tasks.md (задание 1) |
| 1-4 | 🖥️ asciinema | `stage-1/trufflehog-verify.cast` | `trufflehog git . --only-verified` → показать разницу verified vs unverified secrets | 1.5 мин | secrets/tasks.md (задание 2) |
| 1-5 | 🖥️ asciinema | `stage-1/bandit-vs-semgrep.cast` | Запуск Bandit → запуск Semgrep на том же коде → показать уникальные findings каждого | 2 мин | sast/tasks.md (задание 4) |
| 1-6 | 🖥️ asciinema | `stage-1/hadolint-scan.cast` | `hadolint Dockerfile` → цветной output с DL-кодами | 1 мин | linters/tasks.md (задание 3) |

---

### Этап 2 · Зависимости и состав ПО

| ID | Тип | Файл | Что показать | Время | Куда встроить |
|----|-----|------|-------------|-------|---------------|
| 2-1 | 🖥️ asciinema | `stage-2/trivy-fs-vs-image.cast` | `trivy fs .` → `trivy image bkimminich/juice-shop` → показать разницу (OS pkgs vs app deps) | 2 мин | sca/tasks.md (задание 2) |
| 2-2 | 🖥️ asciinema | `stage-2/syft-sbom-generate.cast` | `syft dir:. -o cyclonedx-json` → показать размер SBOM, количество компонентов, `\| jq '.components \| length'` | 1.5 мин | sbom/tasks.md (задание 1) |
| 2-3 | 🖥️ asciinema | `stage-2/grype-sbom-scan.cast` | `syft . > sbom.json && grype sbom:sbom.json` → связка генератор→сканер | 1.5 мин | sca/tasks.md (задание 4) |
| 2-4 | 🎞️ gif | `stage-2/dependency-track-dashboard.gif` | Открытие Dependency-Track → импорт SBOM → dashboard с risk score → policy violations | 15 сек | sbom/tasks.md (задание 3) |
| 2-5 | 🖥️ asciinema | `stage-2/npm-audit-fix.cast` | `npm audit` → показать findings → `npm audit fix --dry-run` → что починится автоматически | 1.5 мин | sca/tasks.md (задание 1) |

---

### Этап 3 · Атакуем приложение

| ID | Тип | Файл | Что показать | Время | Куда встроить |
|----|-----|------|-------------|-------|---------------|
| 3-1 | 🖥️ asciinema | `stage-3/zap-baseline-docker.cast` | `docker run zaproxy zap-baseline.py -t http://...` → поток findings, итоговые PASS/WARN/FAIL | 2 мин | dast/tasks.md (задание 1, шаг 1) |
| 3-2 | 🖥️ asciinema | `stage-3/nuclei-scan.cast` | `nuclei -u http://localhost:3000 -severity critical,high` → template hits, цветной output | 1.5 мин | dast/tasks.md (задание 2) |
| 3-3 | 🖥️ asciinema | `stage-3/ffuf-hidden-paths.cast` | `ffuf -u http://localhost:3000/FUZZ -w common.txt` → находит /ftp, /encryptionkeys, /metrics | 1.5 мин | fuzzing/tasks.md (задание 3) |
| 3-4 | 🎞️ gif | `stage-3/zap-ui-alerts.gif` | ZAP GUI: дерево Alerts → клик на SQL injection → детали, request/response | 15 сек | dast/tasks.md (задание 1) |
| 3-5 | 🖥️ asciinema | `stage-3/schemathesis-run.cast` | `schemathesis run http://localhost:3000/api-docs --stateful=links` → finding 500-х и schema violations | 2 мин | fuzzing/tasks.md (задание 2) |
| 3-6 | 🖥️ asciinema | `stage-3/restler-fuzz.cast` | RESTler compile → test → fuzz-lean → показать найденные 500-е ошибки | 2.5 мин | fuzzing/tasks.md (задание 1) |

---

### Этап 4 · Инфраструктура

| ID | Тип | Файл | Что показать | Время | Куда встроить |
|----|-----|------|-------------|-------|---------------|
| 4-1 | 🖥️ asciinema | `stage-4/dockle-scan.cast` | `dockle bkimminich/juice-shop` → CIS checks: FATAL/WARN/INFO, root user найден | 1 мин | container-sec/tasks.md (задание 3) |
| 4-2 | 🖥️ asciinema | `stage-4/trivy-image-before-after.cast` | `trivy image juice-shop:original` → 180 CVE → `trivy image juice-shop:hardened` → 45 CVE. Wow-эффект | 2 мин | container-sec/tasks.md (задание 5) |
| 4-3 | 🖥️ asciinema | `stage-4/checkov-k8s.cast` | `checkov -d k8s-manifests/` → PASSED/FAILED с CKV-номерами, цветной output | 1.5 мин | iac-sec/tasks.md (задание 1) |
| 4-4 | 🖥️ asciinema | `stage-4/kyverno-reject.cast` | `kubectl apply -f privileged-pod.yaml` → **REJECTED** admission webhook. Затем `kubectl apply -f hardened-pod.yaml` → **created** | 1.5 мин | k8s-sec/tasks.md (задание 4) |
| 4-5 | 🖥️ asciinema | `stage-4/falco-alerts.cast` | `kubectl exec -it pod -- /bin/sh` → в соседнем терминале `kubectl logs falco` → **alert: Terminal shell in container** | 2 мин | k8s-sec/tasks.md (задание 3) |
| 4-6 | 🖥️ asciinema | `stage-4/kubescape-scan.cast` | `kubescape scan framework nsa` → risk score, top failures, remediation | 2 мин | k8s-sec/tasks.md (задание 1) |

---

### Этап 5 · Собираем пайплайн

| ID | Тип | Файл | Что показать | Время | Куда встроить |
|----|-----|------|-------------|-------|---------------|
| 5-1 | 🎞️ gif | `stage-5/github-actions-pr.gif` | GitHub PR → Actions запускаются → SARIF upload → Security tab с findings → Check: PASS/FAIL | 20 сек | ci-cd/tasks.md (задание 2) |
| 5-2 | 🎞️ gif | `stage-5/defectdojo-dashboard.gif` | DefectDojo: Product → Dashboard → findings по severity → дедупликация → trend chart | 20 сек | defectdojo/tasks.md (задание 5) |
| 5-3 | 🖥️ asciinema | `stage-5/defectdojo-import-api.cast` | `./import-reports.sh` → серия импортов через API → "Done! Check dashboard" | 1.5 мин | defectdojo/tasks.md (задание 3) |
| 5-4 | 🖥️ asciinema | `stage-5/quality-gate-run.cast` | `python quality-gate.py --sarif semgrep.sarif --trivy trivy.json` → BLOCKER → **FAIL** (exit 1). Затем после fix → **PASS** (exit 0) | 1.5 мин | quality-gates/tasks.md (задание 1) |
| 5-5 | 🖥️ asciinema | `stage-5/cosign-sign-verify.cast` | `cosign generate-key-pair` → `cosign sign` → `cosign verify` → JSON output с подтверждением подписи | 1.5 мин | supply-chain/tasks.md (задание 1) |
| 5-6 | 🖥️ asciinema | `stage-5/precommit-block.cast` | `git commit` → pre-commit: Gitleaks ✅, hadolint ✅, Semgrep ❌ FAILED → commit blocked | 1 мин | ci-cd/tasks.md (задание 1) |

---

## Сводка

| Этап | Asciinema | GIF | Screenshots | Всего | Общее время записей |
|------|-----------|-----|-------------|-------|---------------------|
| 0 | 1 | 0 | 1 | 2 | ~2 мин |
| 1 | 5 | 0 | 0 | 5 | ~8 мин |
| 2 | 3 | 1 | 0 | 4 | ~7 мин |
| 3 | 4 | 1 | 0 | 5 | ~10 мин |
| 4 | 5 | 0 | 0 | 5 | ~10 мин |
| 5 | 4 | 2 | 0 | 6 | ~8 мин |
| **Итого** | **22** | **4** | **1** | **27** | **~45 мин записей** |

---

## Приоритет записи

Если нет времени записать всё — начните с этих **топ-10 самых ценных**:

| # | ID | Этап | Демо | Почему важно |
|---|----|------|------|-------------|
| 1 | 1-3 | 1 | Gitleaks блокирует коммит | Драматический момент, мотивирует |
| 2 | 4-4 | 4 | Kyverno rejects privileged pod | Второй «wow» момент |
| 3 | 1-1 | 1 | Первый запуск Semgrep | Первый инструмент — первое впечатление |
| 4 | 4-2 | 4 | Trivy: original vs hardened image | Видимый результат работы |
| 5 | 5-4 | 5 | Quality gate FAIL → PASS | Замыкает весь курс |
| 6 | 2-1 | 2 | Trivy fs vs image | Ключевое различие OS vs app |
| 7 | 3-3 | 3 | ffuf находит скрытые пути | Хакерское ощущение |
| 8 | 4-5 | 4 | Falco alert: shell in container | Runtime detection в действии |
| 9 | 5-2 | 5 | DefectDojo dashboard | Визуальный итог всех этапов |
| 10 | 3-1 | 3 | ZAP baseline в Docker | Первый DAST — видно поток findings |

---

## Чеклист для записи

- [ ] Терминал чистый, шрифт крупный, prompt короткий
- [ ] Команды заранее записаны — не импровизируйте
- [ ] Пауза 2 сек перед и после ключевого момента
- [ ] Длина ≤ 3 минуты (asciinema) или ≤ 20 секунд (GIF)
- [ ] Файл назван по ID из каталога (1-3-gitleaks-precommit.cast)
- [ ] Проверено воспроизведение: `asciinema play file.cast`
- [ ] Загружено на asciinema.org (или локально в assets/demos/)
- [ ] Ссылка/embed добавлены в соответствующий tasks.md
