# Board Game App

Платформа для бронирования, поиска и обсуждения настольных игр с админ-панелью и кроссплатформенным мобильным приложением.

[![Go Version](https://img.shields.io/badge/Go-1.23+-00ADD8?style=flat&logo=go)](https://go.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-4169E1?style=flat&logo=postgresql)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-✓-2496ED?style=flat&logo=docker)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## О проекте

Современные клубы и кафе настольных игр нуждаются в удобном инструменте для бронирования столов и управления каталогом игр. Board Game App даёт пользователям возможность записаться на игру, оставить отзыв и сохранить понравившиеся позиции в избранное, а администраторам — управлять контентом через мобильное приложение. Система состоит из высокопроизводительного Go-сервера и кроссплатформенного клиента на Flutter, что позволяет запускать сервис на iOS, Android и в вебе из единой кодовой базы.

## Ключевые возможности

- **Бронирование** — создание, просмотр и управление записями на игровые сессии с проверкой доступности.
- **Каталог настольных игр** — пополняемый список игр с подробной информацией и обложками.
- **Ролевая модель** — пользователи и администраторы; администраторы могут добавлять/редактировать игры, управлять бронированиями и контентом.
- **Избранное** — возможность сохранять понравившиеся игры для быстрого доступа.
- **Отзывы и рейтинги** — пользовательские оценки и текстовые рецензии к играм.
- **Аутентификация** — регистрация и вход с разделением прав доступа (Middleware AdminOnly).
- **Тёмная тема** — полноценная поддержка тёмного оформления на клиенте.
- **Миграции БД** — версионирование схемы PostgreSQL для безопасного обновления.

## Стек

| Компонент     | Технология                                 |
|---------------|-------------------------------------------|
| Backend       | Go 1.23+, Gin, pgx (pgxpool), JWT        |
| База данных   | PostgreSQL 15+                            |
| Frontend      | Flutter 3.x (Dart)                        |
| Платформы     | Android  |
| Контейнеризация | Docker, Docker Compose                  |
| Миграции      | SQL (ручные, в папке `migrations/`)      |
| Авторизация   | JWT + кастомный middleware                |


## Описание архитектуры
1. Мобильное приложение отправляет REST-запросы к Go-серверу.
2. Сервер проверяет JWT, разделяет роли (обычный пользователь / админ) и выполняет бизнес-логику.
3. Данные хранятся в PostgreSQL; все изменения применяются через миграции.

## Быстрый старт

### Предварительные требования

- [Docker](https://docs.docker.com/get-docker/) и Docker Compose
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (для запуска клиента)
- [Go 1.23+](https://go.dev/dl/) (для локальной разработки backend)

### Запуск backend

```bash
# 1. Перейти в папку backend
cd backend-go

# 2. Создать .env (пример ниже)
cp .env.example .env

# 3. Запустить PostgreSQL и сервер
docker compose up -d

# 4. Применить миграции (выполняются автоматически при старте)
# Или вручную:
# psql -h localhost -U postgres -d boardgames -f migrations/01_users_table.sql
# ... и так далее по порядку
```

## Переменные окружения backend
```
Переменная	Назначение	По умолчанию
DATABASE_URL	DSN для PostgreSQL	postgres://...
JWT_SECRET	Секретный ключ для JWT	—
PORT	Порт HTTP-сервера	8080
```
## Запуск Flutter-клиента
```bash
cd flutter-frontend
flutter pub get
flutter run -d chrome   # или -d android / -d ios
```
Убедитесь, что backend запущен и доступен (базовый URL можно изменить в файле lib/services/api_service.dart).

## API Reference
```bash
Базовый URL: http://localhost:8080

Метод	Эндпоинт	Роль	Описание
POST	/api/register	Гость	Регистрация нового пользователя
POST	/api/login	Гость	Вход, получение JWT
GET	/api/games	Любая	Список всех настольных игр
POST	/api/games	Admin	Добавить новую игру
PUT	/api/games/:id	Admin	Редактировать игру
GET	/api/games/:id/reviews	Любая	Отзывы к конкретной игре
POST	/api/reviews	Пользоват.	Оставить отзыв
POST	/api/bookings	Пользоват.	Забронировать игру
GET	/api/bookings	Пользоват.	Мои бронирования
POST	/api/favorites	Пользоват.	Добавить в избранное
GET	/api/favorites	Пользоват.	Список избранного
```
## Структура Backend-проекта
```
backend-go/
├── cmd/main.go              # Точка входа, настройка маршрутов
├── internal/
│   ├── config/              # Загрузка конфигурации (переменные окружения)
│   ├── handlers/            # Обработчики HTTP-запросов
│   │   ├── user_handlers.go
│   │   ├── game_handlers.go
│   │   ├── booking_handlers.go
│   │   ├── review_handlers.go
│   │   └── favorite_handlers.go
│   ├── middleware/          # JWT и AdminOnly middleware
│   ├── models/              # Структуры данных (User, Game, Booking и т.д.)
│   └── storage/             # Слой доступа к PostgreSQL (репозиторий)
├── migrations/              # SQL-миграции (09 штук)
├── docker-compose.yml
├── go.mod / go.sum
```

## Структура Flutter-проекта
```
flutter-frontend/
├── lib/
│   ├── models/              # Модели данных (Game, Review, User и т.д.)
│   ├── screens/             # Экраны приложения
│   ├── services/            # HTTP-клиент и бизнес-логика
│   ├── utils/               # Вспомогательные утилиты
│   ├── widgets/             # Переиспользуемые виджеты
│   └── main.dart            # Точка входа
├── assets/images/           # Изображения настольных игр
├── pubspec.yaml
└── ...
```
## Лицензия
MIT © 2026 Royal17x