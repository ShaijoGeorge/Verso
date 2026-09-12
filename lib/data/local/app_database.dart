import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:verso/data/local/entities/user_settings.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Table: cached_progress
// Mirrors the Supabase `user_progress` table so local ↔ cloud stays in sync.
// ---------------------------------------------------------------------------
class CachedProgress extends Table {
  TextColumn get userId => text()();
  IntColumn get bookId => integer()();
  IntColumn get chapterNumber => integer()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get readAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {userId, bookId, chapterNumber};
}

// ---------------------------------------------------------------------------
// Table: offline_write_queue
// FIFO queue of writes that haven't been synced to Supabase yet.
// Each row is one operation (toggle or mark_book).
// ---------------------------------------------------------------------------
class OfflineWriteQueue extends Table {
  IntColumn get id => integer().autoIncrement()(); // FIFO order
  TextColumn get type => text()(); // 'toggle' or 'mark_book'
  IntColumn get bookId => integer()();
  IntColumn get chapterNumber => integer().nullable()(); // null for mark_book
  BoolColumn get isRead => boolean().nullable()(); // null for mark_book
  IntColumn get totalChapters => integer().nullable()(); // null for toggle
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ---------------------------------------------------------------------------
// Database definition
// ---------------------------------------------------------------------------
@DriftDatabase(tables: [CachedProgress, OfflineWriteQueue, UserSettingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 2;

  $UserSettingsTableTable get userSettings => userSettingsTable;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // Safe migration: Add the new column to existing user databases
        if (from < 2) {
          try {
            await m.addColumn(userSettings, userSettings.canonType);
          } catch (_) {
            await m.createTable(userSettings);
          }
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'verso_db');
  }
}
