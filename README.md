<div align="center">
  <img src="assets/app_icon.png" width="100" height="100" alt="VERSO Logo" />
  <h1>VERSO</h1>
  <p><b>Your Personal Scripture Journey, Beautifully Tracked.</b></p>
  <p>A modern, offline-first Bible reading tracker with multi-canon support, bilingual localization, 1-tap multi-account switching, and privacy-first cloud sync.</p>

  [![Flutter Version](https://img.shields.io/badge/Flutter-3.2%2B-02569B?logo=flutter)](https://flutter.dev)
  [![Dart Version](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart)](https://dart.dev)
  [![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)](https://supabase.com)
  [![Drift SQLite](https://img.shields.io/badge/Local%20DB-Drift%20(SQLite)-003B57?logo=sqlite)](https://drift.simonbinder.eu)
  [![Firebase](https://img.shields.io/badge/Observability-Firebase-FFCA28?logo=firebase)](https://firebase.google.com)
  [![Version](https://img.shields.io/badge/Version-v2.0.0-6C63FF)](#)
</div>

---

> [!NOTE]
> **Looking for Verso v1?**  
> The original v1 codebase has been preserved in the [`v1` branch](https://github.com/ShaijoGeorge/Verso/tree/v1) and tagged as [`v1.0.0`](https://github.com/ShaijoGeorge/Verso/releases/tag/v1.0.0).  
> This documentation describes **Verso v2.0**, reflecting the overhauled architecture, multi-canon engine, offline SQLite persistence, and modern design system.

---

## 📥 Direct Download & Installation

Verso is released independently without dependence on proprietary app stores, giving users direct control over their installation and updates:

| Platform | Distribution Channel | Notes |
|:---|:---|:---|
| **Android** | **[Direct APK Download](https://github.com/ShaijoGeorge/Verso/releases)** | Download the latest `.apk` from GitHub Releases or the Verso landing page and install directly. |
| **Web / PWA** | **Direct Web Access** | Open the web version in any modern browser. Supports **Add to Home Screen** on Android and iOS with offline capability and standalone app experience. |
| **iOS** | **PWA & Direct Sideloading** | Install via Safari (**Share → Add to Home Screen**) for full-screen PWA support, or install via TestFlight / signed `.ipa`. |
| **Desktop** | **Local Build** | Native builds available for Windows, macOS, and Linux via Flutter. |

---

## ✨ Features in Verso v2.0

### 📖 Multi-Canon Support
Tailor your reading journey to your faith tradition with full support across 3 distinct biblical canons:
- **Catholic Canon (73 Books)** - Includes all Deuterocanonical books (*Tobit, Judith, 1 & 2 Maccabees, Wisdom, Sirach, Baruch*).
- **Protestant Canon (66 Books)** - Standard Old and New Testament books.
- **Orthodox Canon (77 Books)** - Comprehensive Eastern Orthodox canon including *3 Maccabees, 1 Esdras, Prayer of Manasseh, Psalm 151, and Epistle of Jeremiah*.
- Switch canons anytime from settings without losing recorded progress.

### 🌐 Bilingual Localization (English & Malayalam)
- Full bilingual book title localization across all testaments and canons.
- Malayalam titles follow the widely recognized **POC standard translation**.
- Bilingual Daily Verse experience for daily spiritual enrichment.

### 💾 Offline-First Architecture & SQLite Caching
- Built with **[Drift](https://drift.simonbinder.eu/)** (type-safe SQLite for Flutter).
- Read and mark chapters instantly with **zero latency**, even completely offline.
- **Background Synchronization**: Pending writes are stored in an `OfflineWriteQueue` and automatically synced to Supabase when network connectivity is restored.
- **User-Scoped Isolation**: Local SQLite tables are isolated per user ID to prevent accidental data contamination during account swaps.

### 🔄 1-Tap Multi-Account Switching
- Effortlessly switch between multiple accounts on a shared device.
- Hardware-backed secure credential storage via **Android Keystore** and **iOS Keychain** (`flutter_secure_storage`).
- Clean session reset between accounts prevents profile state leakage.

### 📊 Advanced Visual Analytics & Habits
- **Daily Reading Streaks**: Stay motivated with persistent streak tracking.
- **Interactive Charts**: Weekly and monthly activity heatmaps and bar charts powered by `fl_chart`.
- **Tabbed Stats Navigation**: Seamlessly filter performance by week, month, year, or all-time.
- **Visual Progress Bars**: Real-time completion percentages for both Old and New Testaments.
- **Activity Log**: Detailed chronological log of recently completed books and chapters.

### 🔥 Streak Freeze & Celebration Overlays
- **Streak Freeze Protection**: Protect your hard-earned streak on busy days with milestone rewards.
- **Celebration Overlays**: Interactive confetti animations when completing milestones or recording your first read.

### 🎂 Birthday Blessings & Daily Reminders
- Personalized annual birthday celebration screen with scripture greetings.
- Customizable local notification reminders and daily verse notifications (supporting Android 13+ runtime permissions).

### 🎨 Modern Design System & Theme Profiles
- Designed from the ground up on **Material 3** principles with smooth micro-interactions.
- **Pure AMOLED Dark Mode**: True black (`#000000`) surfaces for maximum OLED battery savings and nighttime reading comfort.
- **Curated Theme Profiles**: Choose between bespoke aesthetic themes:
  - *Sacred Blue* (Deep Navy × Soft Sky × Warm Gold)
  - *Candy Pop*
  - *Heritage Burgundy*
  - *Limelight*
- **Day/Night Theme Scheduling**: Automatically switch themes based on your preferred schedule.
- **In-App Font Scaling**: Responsive typography scaling from Small (85%) up to Extra Large (130%).

### ⚖️ Legal Hub & Account Governance
- Complete transparency with in-app **Privacy Policy**, **Terms of Use**, and the **Our Mission** story screen.
- One-tap **In-App Account Deletion** with automated cloud data purging.

### 🔗 Custom Deep Linking
- Configured with dedicated `verso://` deep linking scheme (handling `verso://reset-callback` and `verso://email-callback`) to eliminate third-party URL collision issues.

### 🛡️ Observability & Crash Reporting
- Integrated with **Firebase Core & Crashlytics** for robust runtime monitoring.
- Non-fatal network exceptions are cleanly categorized to keep telemetry actionable.

---

## 🛠️ Tech Stack

| Category | Technology | Usage |
|:---|:---|:---|
| **Framework** | **Flutter 3.2+** (Dart 3) | Cross-platform mobile, desktop, and web application framework |
| **Backend & Auth** | **Supabase** | Cloud PostgreSQL database, Row Level Security (RLS), and authentication |
| **State Management** | **Flutter Riverpod 3** + `riverpod_generator` | Reactive dependency injection and declarative state management |
| **Navigation** | **GoRouter 17** | Declarative URL routing, path parameters, and deep link resolution |
| **Local Database** | **Drift 2.22** + `drift_flutter` | Offline-first SQLite persistence and background write queue |
| **Secure Storage** | **flutter_secure_storage** | Hardware-backed keystore/keychain storage for multi-account tokens |
| **Preferences** | **shared_preferences** | Fast local storage for non-sensitive theme and layout settings |
| **Notifications** | **flutter_local_notifications** + `timezone` | Scheduled reminders and daily verses |
| **Observability** | **Firebase Crashlytics & Analytics** | Fatal/non-fatal exception tracking and stability telemetry |
| **Charts** | **fl_chart** | Interactive weekly/monthly progress and habit visualizations |
| **Typography** | **Google Fonts** (`Plus Jakarta Sans`) | Modern, legible typography tailored for scripture layouts |

---

## 🏁 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.2.0 < 4.0.0`)
- A [Supabase](https://supabase.com/) project (with Auth and PostgreSQL enabled)
- A [Firebase](https://firebase.google.com/) project (optional for local dev, required for Crashlytics)

---

### Installation & Local Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ShaijoGeorge/verso.git
   cd verso
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Compile-Time Environment:**

   Verso v2 uses compile-time `--dart-define` parameters for improved security and zero runtime `.env` asset leaks.  
   Copy `.env.example` to `.env` in the repository root:

   ```bash
   cp .env.example .env
   ```

   Fill in your Supabase credentials in `.env`:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-supabase-anon-key
   ```

4. **Run Code Generation (Drift & Riverpod):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Set up Supabase Database:**

   Run the following migration in your **Supabase Dashboard → SQL Editor** to initialize the progress tracking table and Row Level Security:

   ```sql
   -- Create progress tracking table
   create table public.user_progress (
     user_id uuid not null references auth.users (id) on delete cascade,
     book_id int not null,
     chapter_number int not null,
     is_read boolean default false,
     read_at timestamp with time zone,
     primary key (user_id, book_id, chapter_number)
   );

   -- Enable Row Level Security (RLS)
   alter table public.user_progress enable row level security;

   -- Policy: Users can only read their own progress
   create policy "Users can view their own progress"
   on public.user_progress for select
   using (auth.uid() = user_id);

   -- Policy: Users can insert, update, and delete their own progress
   create policy "Users can modify their own progress"
   on public.user_progress for all
   using (auth.uid() = user_id);
   ```

6. **Launch the Application:**

   ```bash
   flutter run --dart-define-from-file=.env
   ```

   > **Tip for VS Code users:** You can directly launch or debug using the preconfigured **Verso (Debug)**, **Verso (Profile)**, or **Verso (Release)** targets in `.vscode/launch.json`.

---

## 📂 Project Architecture

```
lib/
├── core/                        # Core infrastructure & shared modules
│   ├── constants.dart           # Compile-time constants & deep link schemes
│   ├── design/                  # Design system: tokens, theme profiles, colors, typography
│   │   ├── components/          # Reusable design components (VersoBottomSheet, buttons, cards)
│   │   ├── profiles/            # Theme profiles (Sacred Blue, Candy Pop, Heritage Burgundy, Limelight)
│   │   └── tokens/              # Radii, spacing, colors, typography tokens
│   ├── providers/               # App-wide core providers (PackageInfo, network status)
│   ├── router.dart              # GoRouter route declarations and redirect logic
│   ├── transitions/             # Custom page transitions (slide-up, fade-through)
│   └── utils/                   # Crash reporter, error observer, formatters
├── data/                        # Static datasets & local storage
│   ├── bible_book_names.dart    # Malayalam (POC) book translation maps
│   ├── bible_data.dart          # Canonical book specifications (Catholic, Protestant, Orthodox)
│   └── local/                   # Drift (SQLite) database
│       ├── app_database.dart    # Schema: CachedProgress, OfflineWriteQueue, UserSettings
│       └── entities/            # Local table entities and enums
├── features/                    # Feature modules
│   ├── about/                   # Legal hub, Privacy Policy, Terms of Use, Our Mission
│   ├── auth/                    # Auth, Multi-Account switcher, Profile, Password recovery
│   ├── home/                    # Dashboard, Daily Verse, Birthday celebration, Streak freeze
│   ├── intro/                   # Splash screen, Onboarding flow, Profile setup
│   ├── reading/                 # Bible book explorer, Chapter grids, Mark read/unread, sync
│   ├── settings/                # Canons, Languages, Themes, AMOLED, Reminders, Debug cache
│   └── stats/                   # Detailed stats, interactive charts, reading logs
├── firebase_options.dart        # Platform Firebase configuration
└── main.dart                    # Application entry point & service initialization
```

---

## 🌿 Git Branching Strategy

- **`master`** - Stable, production-ready code.
- **`dev`** - Active development branch where new features and enhancements are integrated.
- **`test`** - Staging branch used for release verification, QA audits, and testing.
- **`v1`** - Preserved legacy Verso v1 codebase (anchored at `v1.0.0`).

---

## 🤝 Contributing

Contributions, feedback, and issue reports are always welcome!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request against `dev`

---

## 👨‍💻 Author

**Developed by:** [Shaijo George](https://github.com/ShaijoGeorge)

---

## 🙏 Acknowledgments

- The Flutter and Dart developer community for their incredible ecosystem.
- [Supabase](https://supabase.com/) for empowering privacy-first cloud authentication and database services.
- [Drift](https://drift.simonbinder.eu/) for providing robust, offline-first SQLite persistence.
- Everyone using Verso to nurture a daily scripture habit.

---

<div align="center">
  <sub>Built with ❤️ by Shaijo George</sub>
</div>

