# VS Code mein Shifter run karna

## 1. Folder open karo

**File → Open Folder** → `D:\priyautrav`

(Purana `Utrav_NextGen` mat kholo — `priyautrav` use karo.)

---

## 2. Backend start (sabse important)

### Tarika A — Terminal

1. **Terminal → New Terminal** (`Ctrl + `` ` ``)
2. Run:

```powershell
cd backend
npm install
npm run dev
```

Jab dikhe: `Shifter API listening on http://localhost:3000` — backend ready.

### Tarika B — Run & Debug

1. Left side **Run and Debug** (Ctrl+Shift+D)
2. Dropdown: **Shifter Backend (Node)**
3. Green **Play** ▶

### Tarika C — Task

1. **Terminal → Run Task…**
2. **Shifter: Backend (npm run dev)**

---

## 3. Browser se check

- API: http://localhost:3000/health
- Docs: http://localhost:3000/api/docs
- **Phone wali app (browser):** http://localhost:3000/app/

---

## 4. Flutter mobile (optional — jab SDK theek ho)

1. Extension install: **Flutter** + **Dart**
2. Terminal:

```powershell
. D:\priyautrav\scripts\env.ps1
cd mobile
flutter pub get
flutter run
```

Pehle `flutter create . --project-name shifter --platforms=android` ek baar chala lena agar `android` folder incomplete ho.

---

## 5. Database pehli baar

Terminal:

```powershell
cd backend
npm run db:setup
```

(Postgres password script ko chahiye ho to: `node scripts/auto-setup-db.js YOUR_PASSWORD`)

---

## Shortcuts

| Kaam | Command |
|------|---------|
| Terminal | Ctrl + ` |
| Run backend debug | F5 (launch config select karke) |
| Stop backend | Terminal mein Ctrl+C |
