# Инструкция по установке AI Chat Flutter

## 📋 Системные требования

### Общие требования
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (версия 3.6.0 или выше)
- Git
- Редактор кода (VS Code или Android Studio)

### Для Android разработки
- Android Studio
- Android SDK (API 21 или выше)
- Java Development Kit (JDK) 17 или выше

### Для Windows разработки
- Windows 10 или выше
- Visual Studio 2019 или выше с "Desktop development with C++" workload
- Windows 10 SDK

### Для iOS разработки (опционально)
- macOS с Xcode
- CocoaPods

## 🚀 Быстрая установка

### 1. Клонирование репозитория
```bash
git clone https://github.com/D4us-M4chanicus/AI_CHAT_Flutter.git
cd AI_CHAT_Flutter
```

### 2. Установка зависимостей
```bash
flutter pub get
```

### 3. Запуск приложения
```bash
# Для Android (эмулятор или устройство)
flutter run

# Для Windows
flutter run -d windows

# Для веб (тестирование)
flutter run -d chrome
```

### 4. Первоначальная настройка
1. Откройте приложение
2. Перейдите в раздел "Настройки" (нижняя панель)
3. Выберите провайдера API:
   - **OpenRouter.ai** - для международного использования
   - **VseGPT.ru** - для пользователей из России
4. Введите ваш API ключ
5. Настройте параметры генерации (опционально)
6. Нажмите "Тест соединения" для проверки
7. Сохраните настройки

## 🔧 Подробная установка

### Установка Flutter SDK

#### Windows
1. Скачайте Flutter SDK с [официального сайта](https://flutter.dev/docs/get-started/install/windows)
2. Распакуйте архив в папку (например, `C:\flutter`)
3. Добавьте `C:\flutter\bin` в переменную PATH
4. Перезапустите командную строку
5. Проверьте установку: `flutter doctor`

#### macOS
```bash
# Используя Homebrew
brew install flutter

# Или скачайте с официального сайта
# https://flutter.dev/docs/get-started/install/macos
```

#### Linux
```bash
# Скачайте и распакуйте Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz
tar xf flutter_linux_3.x.x-stable.tar.xz

# Добавьте в PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Добавьте в ~/.bashrc или ~/.zshrc для постоянного использования
echo 'export PATH="$PATH:/path/to/flutter/bin"' >> ~/.bashrc
```

### Настройка Android разработки

#### 1. Установка Android Studio
1. Скачайте [Android Studio](https://developer.android.com/studio)
2. Установите с настройками по умолчанию
3. Запустите Android Studio и пройдите первоначальную настройку

#### 2. Настройка Android SDK
1. Откройте Android Studio
2. Перейдите в `Tools > SDK Manager`
3. Установите:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android SDK Platform-Tools
   - Android API 33 или выше

#### 3. Настройка эмулятора
1. В Android Studio: `Tools > AVD Manager`
2. Нажмите "Create Virtual Device"
3. Выберите устройство (рекомендуется Pixel 6)
4. Выберите системный образ (API 33+)
5. Завершите создание эмулятора

#### 4. Проверка настройки
```bash
flutter doctor
```
Убедитесь, что все пункты Android отмечены зеленым.

### Настройка Windows разработки

#### 1. Установка Visual Studio
1. Скачайте [Visual Studio Community](https://visualstudio.microsoft.com/vs/community/)
2. При установке выберите workload "Desktop development with C++"
3. Убедитесь, что установлены:
   - Windows 10 SDK
   - Visual C++ tools for CMake

#### 2. Включение режима разработчика
1. Откройте `Настройки > Обновление и безопасность > Для разработчиков`
2. Включите "Режим разработчика"

#### 3. Настройка Flutter для Windows
```bash
flutter config --enable-windows-desktop
flutter doctor
```

### Настройка VS Code (рекомендуется)

#### 1. Установка расширений
- Flutter
- Dart
- Flutter Widget Snippets (опционально)

#### 2. Настройка
1. Откройте VS Code
2. Нажмите `Ctrl+Shift+P` и введите "Flutter: New Project"
3. Убедитесь, что Flutter SDK обнаружен

## 🔑 Получение API ключей

### OpenRouter.ai
1. Перейдите на [openrouter.ai](https://openrouter.ai)
2. Зарегистрируйтесь или войдите в аккаунт
3. Перейдите в раздел "API Keys"
4. Создайте новый API ключ
5. Скопируйте ключ (он начинается с `sk-or-`)

### VseGPT.ru
1. Перейдите на [vsegpt.ru](https://vsegpt.ru)
2. Зарегистрируйтесь или войдите в аккаунт
3. Перейдите в раздел API
4. Создайте новый API ключ
5. Скопируйте ключ

## 🏃‍♂️ Запуск приложения

### Android
```bash
# Запуск эмулятора (если не запущен)
flutter emulators --launch <emulator_id>

# Запуск приложения
flutter run

# Или для конкретного устройства
flutter run -d <device_id>
```

### Windows
```bash
flutter run -d windows
```

### Веб (для тестирования)
```bash
flutter run -d chrome
```

### Горячие клавиши во время разработки
- `r` - Hot reload (быстрая перезагрузка)
- `R` - Hot restart (полная перезагрузка)
- `q` - Выход из режима отладки

## 🔨 Сборка приложения

### Android APK
```bash
# Debug версия
flutter build apk --debug

# Release версия
flutter build apk --release

# Split APK по архитектурам (меньший размер)
flutter build apk --split-per-abi
```

### Windows
```bash
# Release версия
flutter build windows --release
```

### Расположение собранных файлов
- **Android APK**: `build/app/outputs/flutter-apk/`
- **Windows**: `build/windows/runner/Release/`

## 🛠️ Разработка и отладка

### Полезные команды
```bash
# Проверка состояния Flutter
flutter doctor -v

# Очистка кэша
flutter clean

# Обновление зависимостей
flutter pub get

# Запуск тестов
flutter test

# Анализ кода
flutter analyze
```

### Отладка
1. Используйте VS Code с расширением Flutter
2. Установите точки останова в коде
3. Запустите в режиме отладки (F5)
4. Используйте Flutter Inspector для анализа UI

### Логи приложения
- В приложении: Меню → "Скачать логи"
- В консоли: `flutter logs`
- Android: `adb logcat`

## ❗ Решение проблем

### Проблемы с Flutter Doctor
```bash
# Если не найден Android SDK
flutter config --android-sdk /path/to/android/sdk

# Если не найден Android Studio
flutter config --android-studio-dir /path/to/android/studio
```

### Проблемы с зависимостями
```bash
# Очистка и переустановка
flutter clean
flutter pub get

# Обновление Flutter
flutter upgrade
```

### Проблемы с Android
```bash
# Принятие лицензий Android SDK
flutter doctor --android-licenses

# Переустановка Android toolchain
sdkmanager --install "build-tools;33.0.0"
```

### Проблемы с Windows
- Убедитесь, что Visual Studio установлен с C++ workload
- Проверьте, что включен режим разработчика Windows
- Перезапустите командную строку после изменения PATH

### Проблемы с API
1. **Ошибка авторизации**: Проверьте правильность API ключа
2. **Ошибка сети**: Проверьте интернет-соединение
3. **Недостаточно средств**: Пополните баланс у провайдера
4. **Неверный провайдер**: Убедитесь, что выбран правильный провайдер для вашего ключа

## 📱 Тестирование на устройствах

### Android устройство
1. Включите "Режим разработчика" на устройстве
2. Включите "Отладка по USB"
3. Подключите устройство к компьютеру
4. Разрешите отладку при появлении запроса
5. Проверьте: `flutter devices`
6. Запустите: `flutter run`

### iOS устройство (требует macOS)
1. Подключите устройство к Mac
2. Откройте проект в Xcode: `open ios/Runner.xcworkspace`
3. Настройте подписание приложения
4. Запустите через Xcode или `flutter run`

## 🔄 Обновление

### Обновление Flutter
```bash
flutter upgrade
```

### Обновление зависимостей проекта
```bash
flutter pub upgrade
```

### Обновление приложения
1. Получите последние изменения: `git pull`
2. Обновите зависимости: `flutter pub get`
3. Перезапустите приложение

## 📞 Поддержка

Если у вас возникли проблемы:
1. Проверьте раздел "Решение проблем" выше
2. Убедитесь, что `flutter doctor` не показывает ошибок
3. Проверьте логи приложения
4. Создайте issue в репозитории проекта

---

**Примечание**: Данная инструкция актуальна для Flutter SDK 3.6.0+. Для более старых версий могут потребоваться дополнительные настройки.
