# NexoryApk

Android-версия **Nexory** — тот же UI и функции, что в [NexoryIos](https://github.com/ioqeeqo-create/NexoryIos): VK, Яндекс «Моя волна», SoundCloud, gateway, темы с обложек.

## Сборка APK (GitHub Actions)

1. **Actions → Build Android APK → Run workflow** (или push в `master`)
2. Скачай **Releases** → `Nexory.apk` или artifact `Nexory-apk-*`
3. Установи на телефон (разреши установку из неизвестных источников)

Секреты GitHub **не нужны**. Собирается **debug APK** (без подписи Play Store) — для личной установки, как неподписанный IPA на iOS.

## Gateway

Тот же **flow-mobile-gateway**, что для iOS:

```bash
FLOW_MOBILE_GATEWAY_SECRET=... node server/flow-mobile-gateway.js
```

В приложении: **Настройки → Gateway URL + Secret + токены**.

## SoundCloud OAuth

Redirect URI в приложении SoundCloud: `nexory://oauth/soundcloud` (как на iOS).

## Локально (только веб)

```bash
npm install
npx serve www -p 8080
```

## Android Studio (опционально)

```bash
npm install
npx cap add android   # первый раз
npx cap sync android
npx cap open android
```

## Синхронизация с iOS

Веб-слой `www/` копируется из NexoryIos. После правок в iOS обнови Android:

```bash
# из корня NexoryApk
robocopy ..\NexoryIos\www www /E
git add www && git commit -m "Sync www from NexoryIos"
```

Подробнее: [NexoryIos/HOW-IT-WORKS.md](https://github.com/ioqeeqo-create/NexoryIos/blob/master/HOW-IT-WORKS.md)
