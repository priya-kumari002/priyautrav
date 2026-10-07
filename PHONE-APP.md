# Phone par Shifter (bina Flutter / APK)

Flutter SDK PC par theek nahi hai, isliye **poori app browser mein** backend ke saath chalti hai — koi alag file bhejne ki zaroorat nahi.

## Step 1 — PC par backend chalu

```powershell
cd D:\priyautrav\backend
npm run dev
```

## Step 2 — Wi‑Fi Private + firewall (pehle wale steps)

## Step 3 — Phone Chrome mein kholo

```
http://192.168.29.248:3000/app/
```

(IP badla ho to `ipconfig` se naya IPv4 likho.)

## Step 4 — Use karo

1. 10 digit phone → Continue  
2. OTP (screen par Dev OTP ya PC terminal)  
3. Transport → Location → Order → Save  

**Home screen shortcut (Android):** Chrome menu → *Add to Home screen* — app jaisa icon ban jayega.

---

## Agar baad mein real APK chahiye

PC par Flutter theek hone ke baad:

```powershell
. D:\priyautrav\scripts\env.ps1
cd D:\priyautrav\mobile
flutter build apk --debug
```

File: `mobile\build\app\outputs\flutter-apk\app-debug.apk`
