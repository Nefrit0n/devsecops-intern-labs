# Поверхность атаки · Juice Shop · Эталонное решение

## HTTP-эндпоинты (выборка ключевых)

| # | Путь | Метод | Аутентификация | Пользовательский ввод | Описание |
|---|------|-------|----------------|----------------------|----------|
| 1 | /rest/user/login | POST | Нет | email, password (JSON body) | Вход в систему |
| 2 | /rest/user/register | POST | Нет | email, password, repeat | Регистрация |
| 3 | /rest/products/search | GET | Нет | q (query param) | Поиск товаров — **SQL injection** |
| 4 | /api/Users | GET | Bearer token | — | Список пользователей |
| 5 | /api/Users/{id} | GET | Bearer token | id (path param) | Данные пользователя — **BOLA** |
| 6 | /api/Products | GET | Нет | — | Каталог товаров |
| 7 | /api/Feedbacks | POST | Bearer token | comment, rating (JSON) | Отзыв — **Stored XSS** |
| 8 | /api/BasketItems | POST | Bearer token | ProductId, quantity | Добавление в корзину |
| 9 | /rest/basket/{id} | GET | Bearer token | id (path param) | Просмотр корзины — **BOLA** |
| 10 | /profile/image/upload | POST | Bearer token | file (multipart) | Загрузка аватара — **file upload** |
| 11 | /redirect | GET | Нет | to (query param) | Редирект — **Open redirect** |
| 12 | /rest/user/change-password | GET | Bearer token | current, new, repeat | Смена пароля |
| 13 | /api/Complaints | POST | Bearer token | message, file | Жалоба с вложением |
| 14 | /rest/user/whoami | GET | Bearer token | — | Информация о текущем пользователе |
| 15 | /#/score-board | GET | Нет | — | Скрытая страница Score Board |

## Формы и поля ввода

| # | Страница | Поле | Тип данных | Валидация на фронте | Валидация на бэке |
|---|----------|------|------------|--------------------|--------------------|
| 1 | Login | email | string | Angular validation | Нет (SQL injection) |
| 2 | Login | password | string | minlength=1 | Нет |
| 3 | Register | email | email | Angular email validator | Частичная |
| 4 | Search | q | string | Нет | Нет (SQL injection) |
| 5 | Feedback | comment | string | maxlength=160 (обходится) | Нет (Stored XSS) |
| 6 | Contact | message | string | required | Частичная |

## Загрузка файлов

| # | Эндпоинт | Типы файлов | Макс. размер | Куда сохраняется |
|---|----------|-------------|--------------|------------------|
| 1 | /profile/image/upload | Любые (нет проверки!) | ~100KB | /uploads/ |
| 2 | /api/Complaints (file) | PDF (заявлено) | Не ограничен | /uploads/ |

## Итог

- Всего HTTP-эндпоинтов: ~45 (REST API + routes)
- Из них без аутентификации: ~15 (login, register, search, products, redirect)
- Форм с пользовательским вводом: 8+
- Точек загрузки файлов: 2
- Скрытые эндпоинты: /ftp, /encryptionkeys, /metrics, /#/score-board
