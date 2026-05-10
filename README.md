# local-storage-and-data-persistence
# MyMoney — Personal Expense Tracker

**Course:** Mobile Application Development  
**Unit:** 5 — Local Storage & Data Persistence  
**Assessment:** Graded Exercise (10%)

---

## Student Information

| Field | Details |
|-------|---------|
| **Full Name** | Kaleab Adane |
| **Student ID** | ATE/5365/13 |
| **Instructor** | Abel Tadesse |

---

## How to Run the App

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd unit5_assessment
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

> **Requirements:** Flutter SDK 3.16+, Android emulator / iOS simulator / physical device with USB debugging enabled. Set `minSdkVersion` to at least **21** in `android/app/build.gradle` (required by sqflite).

---

## Project Structure

```
unit5_assessment/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── expense.dart
│   ├── services/
│   │   ├── pin_vault.dart        # flutter_secure_storage
│   │   ├── prefs_service.dart    # shared_preferences
│   │   └── expenses_db.dart      # sqflite
│   └── screens/
│       ├── pin_screen.dart
│       ├── expenses_screen.dart
│       ├── expense_editor.dart
│       └── settings_screen.dart
└── README.md
```

---

## Storage Design — Why Each Type Was Chosen

### 1. `flutter_secure_storage` → PIN (`pin_vault.dart`)
The 4-digit PIN is security-sensitive credentials. Storing it in plain `SharedPreferences` would expose it as readable plaintext XML on any rooted Android device (verifiable via `adb shell run-as <pkg> cat shared_prefs/...xml`). `flutter_secure_storage` encrypts the value using the Android Keystore / iOS Keychain, so even with file-system access the PIN cannot be read. This is the correct choice for any secret the user trusts the app to protect.

### 2. `sqflite` (SQLite) → Expenses (`expenses_db.dart`)
Expense records are structured, queryable data: many rows, multiple columns (amount, category, note, date), and the need to sort by date and aggregate by month (`SUM`). SharedPreferences is designed for a handful of primitive key-value pairs and cannot run SQL queries. SQLite via `sqflite` gives full CRUD, parameterized queries (preventing SQL injection), and efficient indexed lookups — the right fit for any list of user-generated records.

### 3. `shared_preferences` → Settings (`prefs_service.dart`)
Currency symbol and theme choice are exactly what SharedPreferences was designed for: small, non-sensitive primitive values (a `String` and a `bool`) that need to survive app restarts. They are not secret, not structured, and there are only two of them — SQLite would be heavy overkill, and secure storage is unnecessary for non-sensitive preferences.

---

## Features Implemented

- **R1 — App PIN (Secure Storage):** First-launch PIN setup, PIN verification on every launch, Reset PIN + wipe all data.
- **R2 — Expense Database (SQLite):** Full CRUD on expenses table, monthly SUM query, list sorted by date DESC, swipe-to-delete, tap-to-edit.
- **R3 — Preferences (SharedPreferences):** Currency (ETB / USD / EUR) and theme (light / dark) persist across launches and apply globally.
- **R4 — Code Quality:** Each storage type isolated in its own service file; UI screens only call service classes; all SQL uses `whereArgs`; no file exceeds ~250 lines.
- **R5 — Demo Video:** Screen recording (≤ 3 min) linked below showing PIN setup → add 3 expenses → edit → delete → change currency → restart → unlock.

---


---

## Academic Integrity Disclosure

The structure and service patterns in this project are based on the Unit 5 Lab Manual provided by the instructor. No other student's code was copied. AI assistance (Claude) was used to help generate the README template and review code structure; all application code was written and understood by the student.
