# STRIDE-анализ · Juice Shop · Эталонное решение

## Анализ по trust boundaries

| # | Поток (trust boundary) | S | T | R | I | D | E | Сценарий атаки | Severity | Мера |
|---|------------------------|---|---|---|---|---|---|----------------|----------|------|
| 1 | User → Frontend (HTTP) | ✓ | | | ✓ | | | **S:** Подмена сессии — JWT без проверки exp. **I:** Перехват данных — нет HSTS, HTTP-only cookies | HIGH | HTTPS + HSTS + Secure cookies |
| 2 | User → Search (/rest/products/search) | | ✓ | | | | | **T:** SQL injection через параметр q — `q=')) UNION SELECT...` | CRITICAL | Параметризованные запросы (Sequelize) |
| 3 | User → Feedback (/api/Feedbacks) | | ✓ | | | | ✓ | **T:** Stored XSS в поле comment — `<script>alert(1)</script>`. **E:** Обход maxlength через Burp/curl | HIGH | Content-Security-Policy + DOMPurify |
| 4 | User → Login (/rest/user/login) | ✓ | | | | ✓ | | **S:** Credential stuffing — нет rate limit. **D:** Brute force → account lockout | HIGH | Rate limiting + CAPTCHA после 5 попыток |
| 5 | Frontend → Backend API (REST) | | ✓ | | | | ✓ | **T:** CSRF — нет anti-CSRF token для state-changing ops. **E:** BOLA — /api/Users/{id} без проверки ownership | HIGH | CSRF tokens + проверка ownership в middleware |
| 6 | Backend → Database (SQL) | | ✓ | | ✓ | | | **T:** SQL injection из search propagates. **I:** Error messages с SQL stack trace → information disclosure | CRITICAL | Prepared statements + custom error handler |
| 7 | Backend → File System (uploads) | | ✓ | | ✓ | | ✓ | **T:** Malicious file upload (webshell). **I:** Directory traversal через filename. **E:** File overwrite → code execution | HIGH | Whitelist extensions + rename + sandbox |
| 8 | User → Redirect (/redirect) | ✓ | | | | | | **S:** Open redirect — attacker создаёт phishing URL через /redirect?to=evil.com | MEDIUM | Whitelist allowed redirect domains |
| 9 | Backend (логирование) | | | ✓ | | | | **R:** Отсутствие audit log — невозможно доказать кто совершил действие | MEDIUM | Structured logging с user_id, IP, action |
| 10 | Frontend (Angular SPA) | | | | | ✓ | | **D:** ReDoS через сложный regex в валидации email | LOW | Ограничение regex complexity, timeout |
| 11 | User → Admin panel | | | | | | ✓ | **E:** Доступ к /#/administration без проверки роли (client-side only) | HIGH | Server-side role check на admin endpoints |
| 12 | Backend → External (npm) | | ✓ | | | | | **T:** Dependency confusion / malicious package | MEDIUM | Lock file, SCA scan, private registry |

## Поверхность атаки (сводка)

| # | Точка входа | Протокол | Аутентификация | Критичность |
|---|-------------|----------|----------------|-------------|
| 1 | /rest/products/search?q= | HTTP GET | Нет | CRITICAL (SQL injection) |
| 2 | /api/Feedbacks (comment) | HTTP POST | JWT | HIGH (Stored XSS) |
| 3 | /rest/user/login | HTTP POST | Нет | HIGH (brute force) |
| 4 | /api/Users/{id} | HTTP GET | JWT | HIGH (BOLA) |
| 5 | /profile/image/upload | HTTP POST multipart | JWT | HIGH (file upload) |
| 6 | /redirect?to= | HTTP GET | Нет | MEDIUM (open redirect) |

## Итог

- Всего угроз: 17
- CRITICAL: 2 · HIGH: 8 · MEDIUM: 5 · LOW: 2
- Покрытие: S(3) T(6) R(1) I(3) D(2) E(4)

## Сравнение ручного STRIDE vs pytm

| Аспект | Ручной STRIDE | pytm автоматический |
|--------|---------------|---------------------|
| Найдено угроз | 17 | ~25 (включая generic) |
| Бизнес-логика (BOLA, IDOR) | ✓ нашли | ✗ пропустил |
| Generic threats (DDoS, MitM) | Пропустили некоторые | ✓ генерирует все |
| Специфика Juice Shop | ✓ (SQL injection в search) | ✗ (не знает про search) |
| **Вывод** | Глубже для конкретного приложения | Шире, но поверхностнее |
