# Shifter — run on D: drive + test on phone

**Why C: failed:** only ~0.7 GB free. Flutter SDK needs several GB. Everything lives on **D:\priyautrav**.

## 1) One-time: database + API

```powershell
cd D:\priyautrav\backend
.\scripts\setup-windows.ps1 -PostgresPassword "YOUR_POSTGRES_PASSWORD"
npm run dev
```

Keep this window open. API: http://localhost:3000/health

## 2) One-time: Flutter (first run downloads SDK to D:)

```powershell
D:\priyautrav\scripts\env.ps1
cd D:\priyautrav\mobile
flutter create . --project-name shifter --org com.shifter --platforms=android
flutter pub get
```

## 3) Run on phone (USB)

1. Phone: **Developer options** → **USB debugging** ON.
2. Connect USB → allow debugging on phone.
3. PC:

```powershell
D:\priyautrav\scripts\env.ps1
cd D:\priyautrav\mobile
flutter devices
```

4. Set your PC Wi‑Fi IP in `mobile\lib\config\api_config.dart` → `phoneApiHost` (see file comments).
5. Phone and PC on **same Wi‑Fi**. Windows Firewall: allow **Node** / port **3000** on Private network.

```powershell
flutter run
```

## 4) Or install APK (no USB after build)

```powershell
flutter build apk --debug
```

APK: `mobile\build\app\outputs\flutter-apk\app-debug.apk` → copy to phone and install.

## 5) Login test

- Phone number: 10 digits (e.g. `9876543210`)
- OTP: backend terminal shows `[OTP] +91... => 1234` or OTP screen “Dev OTP”

## Find your PC IP

```powershell
ipconfig | findstr /i "IPv4"
```

Use that IP in `phoneApiHost`, e.g. `192.168.1.5`.
