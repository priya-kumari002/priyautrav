# Mobile par Shifter app kaise dekhein

## Pehle check (bina app ke)

1. Phone aur PC **same Wi‑Fi** par hon.
2. Phone ke Chrome mein kholo:

   **http://192.168.29.248:3000/health**

   Agar `{"status":"ok"}` dikhe → backend theek hai.

   Agar na khule → Windows Firewall mein port **3000** allow karo (Private network).

---

## App phone par chalana (2 tareeke)

### Tareeka A — USB se direct run (developer)

1. Phone: **Settings → About phone** → Build number 7 baar tap → Developer options ON.
2. **USB debugging** ON, USB cable se PC se jodo.
3. PC par:

```powershell
. D:\priyautrav\scripts\env.ps1
cd D:\priyautrav\mobile
flutter create . --project-name shifter --org com.shifter --platforms=android
flutter pub get
flutter devices
flutter run
```

4. App phone par install ho kar khul jayegi.

### Tareeka B — APK bana kar bhejna (USB ke bina install)

```powershell
. D:\priyautrav\scripts\env.ps1
cd D:\priyautrav\mobile
flutter build apk --debug
```

APK file:

`D:\priyautrav\mobile\build\app\outputs\flutter-apk\app-debug.apk`

Isko WhatsApp / Drive se phone par bhejo, install karo (Unknown sources allow).

---

## Login test

- Phone number: **10 digit** (jaise `9876543210`)
- OTP: PC par backend window mein `[OTP] +91... => 1234` ya app screen par **Dev OTP**

---

## API address

File: `mobile\lib\config\api_config.dart`  
Ab set hai: `192.168.29.248`  
Agar Wi‑Fi badle to `ipconfig` se naya IPv4 yahan likho, phir dubara `flutter run` ya APK build.
