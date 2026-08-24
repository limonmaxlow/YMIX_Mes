<div align="center">

# 📱 YMIX_MesClient

**Кроссплатформенный клиент мессенджера YMix на Flutter**

Flutter · Dart · STOMP/WebSocket

</div>

---

## О проекте

**YMIX_MesClient** - кроссплатформенный клиент на Flutter, работающий в
паре с бэкендом [`YMIX_MesServer`](https://github.com/limonmaxlow/YMix_MesServer/blob/main/README.md).
Приложение реализует полноценный сценарий обмена сообщениями: от
регистрации и входа до переписки в реальном времени.

Поддерживаемые платформы: Android, iOS, Windows, macOS, Web (через
стандартные возможности Flutter).

**Возможности:**

- Регистрация и вход по логину и паролю, JWT-сессия сохраняется между
  запусками приложения
- Список чатов с последним сообщением и счётчиком непрочитанных
- Поиск пользователей и создание нового личного чата
- История переписки с постраничной подгрузкой (пагинация)
- Отправка и получение сообщений в реальном времени через STOMP/WebSocket
- Отметка чата прочитанным
- Экран профиля пользователя

---

## Экраны приложения

| Экран | Файл | Описание |
|---|---|---|
| Splash | `screens/splash_screen.dart` | Проверка сохранённой сессии при запуске |
| Вход | `screens/auth/login_screen.dart` | Авторизация по логину и паролю |
| Регистрация | `screens/auth/register_screen.dart` | Создание нового аккаунта |
| Список чатов | `screens/chats/chat_list_screen.dart` | Все чаты пользователя, обновляется в реальном времени |
| Новый чат | `screens/chats/new_chat_screen.dart` | Поиск пользователя и создание личного чата |
| Переписка | `screens/chat/chat_screen.dart` | История сообщений и обмен в реальном времени |
| Профиль | `screens/profile/profile_screen.dart` | Информация о текущем пользователе |


## Скриншоты приложения

<details>
<summary> Заставка</summary>
<img src="screenshots/Anim.png" width="220"/>
</details>

<details>
<summary> Авторизация</summary>
<img src="screenshots/Auth.png" width="220"/>
<img src="screenshots/Reg.png" width="220"/>
</details>

<details>
<summary> Список чатов</summary>
<img src="screenshots/Main.png" width="220"/>
</details>

<details>
<summary> Переписка</summary>
<img src="screenshots/Chat.png" width="220"/>
<img src="screenshots/ChatProfile.png" width="220"/>
</details>

<details>
<summary> Профиль</summary>
<img src="screenshots/Profile.png" width="220"/>
</details>

<details>
<summary> Настройки</summary>
<img src="screenshots/Settings1.png" width="220"/>
<img src="screenshots/Settings2.png" width="220"/>
<img src="screenshots/Settings3.png" width="220"/>
</details>


---

## Архитектура

```
lib/
├── config/     — адрес бэкенда, тема приложения
├── models/     — User, Chat, Message
├── services/   — работа с бэкендом и хранением сессии
├── screens/    — экраны приложения (auth, chats, chat, profile, splash)
└── widgets/    — переиспользуемые виджеты (chat_tile, message_bubble, ...)
```

**Слой `services/` — сердце клиента:**

| Сервис | Назначение |
|---|---|
| `api_service.dart` | REST-запросы к `YMIX_MesServer` (авторизация, чаты, поиск, история) |
| `ws_service.dart` | STOMP-соединение и подписки для сообщений в реальном времени |
| `session.dart` | Хранение и восстановление JWT-токена через `shared_preferences` |

Экраны обращаются к `api_service` за данными и подписываются на события
`ws_service` для живого обновления списка чатов и переписки. JWT из
`session` автоматически подставляется как в заголовок REST-запросов, так и
в заголовок STOMP CONNECT.

---

## Соответствие экранов и API сервера

| Действие в приложении | Endpoint на `YMIX_MesServer` |
|---|---|
| Регистрация | `POST /api/auth/register` |
| Вход | `POST /api/auth/login` |
| Список чатов | `GET /api/chats`, обновление через `/user/queue/chats` |
| Поиск пользователей | `GET /api/users/search` |
| Создание личного чата | `POST /api/chats/private` |
| История сообщений | `GET /api/chats/{id}/messages` |
| Отправка сообщения | STOMP `/app/chat.send` |
| Приём сообщений | подписка на `/topic/chat.{id}` |
| Отметка «прочитано» | `POST /api/chats/{id}/read` |

---

## Стек

- Flutter (Dart), SDK `>=3.3.0 <4.0.0`

---

## Запуск

Понадобится установленный Flutter SDK и запущенный `YMIX_MesServer`.

** Установить сам проект, а потом установить зависимости и запустить**

```bash
flutter pub get
flutter run
```

**Перед запуском** укажите адрес сервера в `lib/config/constants.dart`:

```dart
static const String apiHost = 'localhost'; // <-- смените
static const int apiPort = 8080;
```

| Платформа | Адрес |
|---|---|
| Android-эмулятор | `10.0.2.2` |
| Desktop / iOS-симулятор / web | `localhost` |
| Реальное устройство | IP компьютера в локальной сети, например `192.168.1.50` |

Для Android дополнительно добавьте в
`android/app/src/main/AndroidManifest.xml` разрешение на сетевые запросы к
локальному серверу без TLS (актуально при разработке):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application ... android:usesCleartextTraffic="true">
```
