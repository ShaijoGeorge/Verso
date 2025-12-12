# VERSO

**VERSO** (formerly Biblia) is a modern Bible reading tracker application built with Flutter. It helps users track their reading progress across the Old and New Testaments, maintain daily reading streaks, and visualize their habits with detailed analytics.

---

## 🚀 Features

### 📚 Comprehensive Tracking
Track reading progress for all 73 books of the Bible (including Deuterocanonical books).

### ☁️ Cloud Sync
Seamlessly syncs reading progress across devices using Supabase.

### 📊 Visual Analytics
- Daily reading streaks
- Interactive charts for weekly and monthly activity
- Visual progress bars for Old and New Testaments

### 🔔 Daily Reminders
Schedule customizable local notifications to build a consistent reading habit.

### 🎨 Modern UI
Beautiful Material 3 design with full Dark Mode support and smooth animations.

### 🔐 Secure Authentication
User sign-up, login, and password management powered by Supabase Auth.

---

## 🛠️ Tech Stack

| Technology | Purpose |
|-----------|---------|
| **Flutter** (Dart) | Framework |
| **Supabase** (PostgreSQL + Auth) | Backend |
| **Flutter Riverpod** | State Management |
| **GoRouter** | Navigation |
| **shared_preferences** & **flutter_secure_storage** | Local Storage |
| **flutter_local_notifications** | Notifications |
| **fl_chart** & **dashed_circular_progress_bar** | Charts |

---

## 📱 Screenshots

### Home & Stats
> Beautiful dashboard showing reading progress, streaks, and completion percentage

### Reading Progress
> Interactive grids for tracking chapters in each book of the Bible

### Settings
> Customizable dark mode, daily reminders, and user preferences

### Dark Mode
> Full dark mode support for comfortable nighttime reading

---

## 🏁 Getting Started

### Prerequisites

- Flutter SDK (3.2.0 or higher)
- A Supabase project

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ShaijoGeorge/verso.git
   cd verso
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Environment Setup:**
   
   Create a `.env` file in the root directory of the project and add your Supabase credentials:
   
   ```env
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Database Setup:**
   
   Run the following SQL in your Supabase SQL Editor to create the necessary table:
   
   ```sql
   -- Create the progress tracking table
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

   -- Create Policy: Users can only see their own data
   create policy "Users can view their own progress"
   on public.user_progress for select
   using (auth.uid() = user_id);

   -- Create Policy: Users can insert/update their own data
   create policy "Users can insert/update their own progress"
   on public.user_progress for all
   using (auth.uid() = user_id);
   ```

5. **Run the App:**
   ```bash
   flutter run
   ```

---

## 📂 Project Structure

```
lib/
├── core/                # Global utilities, theme, router, and constants
├── data/                # Data models and static Bible data
├── features/
│   ├── auth/            # Login, Signup, Profile logic
│   ├── home/            # Home screen dashboard
│   ├── intro/           # Splash screen
│   ├── reading/         # Book grids, chapter tracking screens
│   ├── settings/        # App settings and Notification service
│   └── stats/           # Analytics charts and logic
└── main.dart            # App entry point
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👨‍💻 Developer

**Developed by:** [Shaijo George](https://github.com/ShaijoGeorge)

---

## 🙏 Acknowledgments

- Thanks to the Flutter community for amazing packages
- Supabase for the excellent backend platform
- All contributors who help improve VERSO

---

<div align="center">
  <sub>Built with ❤️ by Shaijo George</sub>
</div>
