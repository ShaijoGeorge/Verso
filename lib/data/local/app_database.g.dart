// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedProgressTable extends CachedProgress
    with TableInfo<$CachedProgressTable, CachedProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
      'book_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _chapterNumberMeta =
      const VerificationMeta('chapterNumber');
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
      'chapter_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
      'read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [userId, bookId, chapterNumber, isRead, readAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_progress';
  @override
  VerificationContext validateIntegrity(Insertable<CachedProgressData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
          _chapterNumberMeta,
          chapterNumber.isAcceptableOrUnknown(
              data['chapter_number']!, _chapterNumberMeta));
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta,
          readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, bookId, chapterNumber};
  @override
  CachedProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProgressData(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_id'])!,
      chapterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_number'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      readAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}read_at']),
    );
  }

  @override
  $CachedProgressTable createAlias(String alias) {
    return $CachedProgressTable(attachedDatabase, alias);
  }
}

class CachedProgressData extends DataClass
    implements Insertable<CachedProgressData> {
  final String userId;
  final int bookId;
  final int chapterNumber;
  final bool isRead;
  final DateTime? readAt;
  const CachedProgressData(
      {required this.userId,
      required this.bookId,
      required this.chapterNumber,
      required this.isRead,
      this.readAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['book_id'] = Variable<int>(bookId);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    return map;
  }

  CachedProgressCompanion toCompanion(bool nullToAbsent) {
    return CachedProgressCompanion(
      userId: Value(userId),
      bookId: Value(bookId),
      chapterNumber: Value(chapterNumber),
      isRead: Value(isRead),
      readAt:
          readAt == null && nullToAbsent ? const Value.absent() : Value(readAt),
    );
  }

  factory CachedProgressData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProgressData(
      userId: serializer.fromJson<String>(json['userId']),
      bookId: serializer.fromJson<int>(json['bookId']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'bookId': serializer.toJson<int>(bookId),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'isRead': serializer.toJson<bool>(isRead),
      'readAt': serializer.toJson<DateTime?>(readAt),
    };
  }

  CachedProgressData copyWith(
          {String? userId,
          int? bookId,
          int? chapterNumber,
          bool? isRead,
          Value<DateTime?> readAt = const Value.absent()}) =>
      CachedProgressData(
        userId: userId ?? this.userId,
        bookId: bookId ?? this.bookId,
        chapterNumber: chapterNumber ?? this.chapterNumber,
        isRead: isRead ?? this.isRead,
        readAt: readAt.present ? readAt.value : this.readAt,
      );
  CachedProgressData copyWithCompanion(CachedProgressCompanion data) {
    return CachedProgressData(
      userId: data.userId.present ? data.userId.value : this.userId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProgressData(')
          ..write('userId: $userId, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, bookId, chapterNumber, isRead, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProgressData &&
          other.userId == this.userId &&
          other.bookId == this.bookId &&
          other.chapterNumber == this.chapterNumber &&
          other.isRead == this.isRead &&
          other.readAt == this.readAt);
}

class CachedProgressCompanion extends UpdateCompanion<CachedProgressData> {
  final Value<String> userId;
  final Value<int> bookId;
  final Value<int> chapterNumber;
  final Value<bool> isRead;
  final Value<DateTime?> readAt;
  final Value<int> rowid;
  const CachedProgressCompanion({
    this.userId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedProgressCompanion.insert({
    required String userId,
    required int bookId,
    required int chapterNumber,
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        bookId = Value(bookId),
        chapterNumber = Value(chapterNumber);
  static Insertable<CachedProgressData> custom({
    Expression<String>? userId,
    Expression<int>? bookId,
    Expression<int>? chapterNumber,
    Expression<bool>? isRead,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (bookId != null) 'book_id': bookId,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (isRead != null) 'is_read': isRead,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedProgressCompanion copyWith(
      {Value<String>? userId,
      Value<int>? bookId,
      Value<int>? chapterNumber,
      Value<bool>? isRead,
      Value<DateTime?>? readAt,
      Value<int>? rowid}) {
    return CachedProgressCompanion(
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProgressCompanion(')
          ..write('userId: $userId, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineWriteQueueTable extends OfflineWriteQueue
    with TableInfo<$OfflineWriteQueueTable, OfflineWriteQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineWriteQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
      'book_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _chapterNumberMeta =
      const VerificationMeta('chapterNumber');
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
      'chapter_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'));
  static const VerificationMeta _totalChaptersMeta =
      const VerificationMeta('totalChapters');
  @override
  late final GeneratedColumn<int> totalChapters = GeneratedColumn<int>(
      'total_chapters', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, bookId, chapterNumber, isRead, totalChapters, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_write_queue';
  @override
  VerificationContext validateIntegrity(
      Insertable<OfflineWriteQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
          _chapterNumberMeta,
          chapterNumber.isAcceptableOrUnknown(
              data['chapter_number']!, _chapterNumberMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('total_chapters')) {
      context.handle(
          _totalChaptersMeta,
          totalChapters.isAcceptableOrUnknown(
              data['total_chapters']!, _totalChaptersMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineWriteQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineWriteQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_id'])!,
      chapterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_number']),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read']),
      totalChapters: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_chapters']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OfflineWriteQueueTable createAlias(String alias) {
    return $OfflineWriteQueueTable(attachedDatabase, alias);
  }
}

class OfflineWriteQueueData extends DataClass
    implements Insertable<OfflineWriteQueueData> {
  final int id;
  final String type;
  final int bookId;
  final int? chapterNumber;
  final bool? isRead;
  final int? totalChapters;
  final DateTime createdAt;
  const OfflineWriteQueueData(
      {required this.id,
      required this.type,
      required this.bookId,
      this.chapterNumber,
      this.isRead,
      this.totalChapters,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['book_id'] = Variable<int>(bookId);
    if (!nullToAbsent || chapterNumber != null) {
      map['chapter_number'] = Variable<int>(chapterNumber);
    }
    if (!nullToAbsent || isRead != null) {
      map['is_read'] = Variable<bool>(isRead);
    }
    if (!nullToAbsent || totalChapters != null) {
      map['total_chapters'] = Variable<int>(totalChapters);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OfflineWriteQueueCompanion toCompanion(bool nullToAbsent) {
    return OfflineWriteQueueCompanion(
      id: Value(id),
      type: Value(type),
      bookId: Value(bookId),
      chapterNumber: chapterNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterNumber),
      isRead:
          isRead == null && nullToAbsent ? const Value.absent() : Value(isRead),
      totalChapters: totalChapters == null && nullToAbsent
          ? const Value.absent()
          : Value(totalChapters),
      createdAt: Value(createdAt),
    );
  }

  factory OfflineWriteQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineWriteQueueData(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      bookId: serializer.fromJson<int>(json['bookId']),
      chapterNumber: serializer.fromJson<int?>(json['chapterNumber']),
      isRead: serializer.fromJson<bool?>(json['isRead']),
      totalChapters: serializer.fromJson<int?>(json['totalChapters']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'bookId': serializer.toJson<int>(bookId),
      'chapterNumber': serializer.toJson<int?>(chapterNumber),
      'isRead': serializer.toJson<bool?>(isRead),
      'totalChapters': serializer.toJson<int?>(totalChapters),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OfflineWriteQueueData copyWith(
          {int? id,
          String? type,
          int? bookId,
          Value<int?> chapterNumber = const Value.absent(),
          Value<bool?> isRead = const Value.absent(),
          Value<int?> totalChapters = const Value.absent(),
          DateTime? createdAt}) =>
      OfflineWriteQueueData(
        id: id ?? this.id,
        type: type ?? this.type,
        bookId: bookId ?? this.bookId,
        chapterNumber:
            chapterNumber.present ? chapterNumber.value : this.chapterNumber,
        isRead: isRead.present ? isRead.value : this.isRead,
        totalChapters:
            totalChapters.present ? totalChapters.value : this.totalChapters,
        createdAt: createdAt ?? this.createdAt,
      );
  OfflineWriteQueueData copyWithCompanion(OfflineWriteQueueCompanion data) {
    return OfflineWriteQueueData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      totalChapters: data.totalChapters.present
          ? data.totalChapters.value
          : this.totalChapters,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineWriteQueueData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('isRead: $isRead, ')
          ..write('totalChapters: $totalChapters, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, type, bookId, chapterNumber, isRead, totalChapters, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineWriteQueueData &&
          other.id == this.id &&
          other.type == this.type &&
          other.bookId == this.bookId &&
          other.chapterNumber == this.chapterNumber &&
          other.isRead == this.isRead &&
          other.totalChapters == this.totalChapters &&
          other.createdAt == this.createdAt);
}

class OfflineWriteQueueCompanion
    extends UpdateCompanion<OfflineWriteQueueData> {
  final Value<int> id;
  final Value<String> type;
  final Value<int> bookId;
  final Value<int?> chapterNumber;
  final Value<bool?> isRead;
  final Value<int?> totalChapters;
  final Value<DateTime> createdAt;
  const OfflineWriteQueueCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.isRead = const Value.absent(),
    this.totalChapters = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OfflineWriteQueueCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required int bookId,
    this.chapterNumber = const Value.absent(),
    this.isRead = const Value.absent(),
    this.totalChapters = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : type = Value(type),
        bookId = Value(bookId);
  static Insertable<OfflineWriteQueueData> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<int>? bookId,
    Expression<int>? chapterNumber,
    Expression<bool>? isRead,
    Expression<int>? totalChapters,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (bookId != null) 'book_id': bookId,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (isRead != null) 'is_read': isRead,
      if (totalChapters != null) 'total_chapters': totalChapters,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OfflineWriteQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<int>? bookId,
      Value<int?>? chapterNumber,
      Value<bool?>? isRead,
      Value<int?>? totalChapters,
      Value<DateTime>? createdAt}) {
    return OfflineWriteQueueCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      bookId: bookId ?? this.bookId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      isRead: isRead ?? this.isRead,
      totalChapters: totalChapters ?? this.totalChapters,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (totalChapters.present) {
      map['total_chapters'] = Variable<int>(totalChapters.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineWriteQueueCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('isRead: $isRead, ')
          ..write('totalChapters: $totalChapters, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedProgressTable cachedProgress = $CachedProgressTable(this);
  late final $OfflineWriteQueueTable offlineWriteQueue =
      $OfflineWriteQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cachedProgress, offlineWriteQueue];
}

typedef $$CachedProgressTableCreateCompanionBuilder = CachedProgressCompanion
    Function({
  required String userId,
  required int bookId,
  required int chapterNumber,
  Value<bool> isRead,
  Value<DateTime?> readAt,
  Value<int> rowid,
});
typedef $$CachedProgressTableUpdateCompanionBuilder = CachedProgressCompanion
    Function({
  Value<String> userId,
  Value<int> bookId,
  Value<int> chapterNumber,
  Value<bool> isRead,
  Value<DateTime?> readAt,
  Value<int> rowid,
});

class $$CachedProgressTableFilterComposer
    extends Composer<_$AppDatabase, $CachedProgressTable> {
  $$CachedProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnFilters(column));
}

class $$CachedProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedProgressTable> {
  $$CachedProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedProgressTable> {
  $$CachedProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$CachedProgressTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedProgressTable,
    CachedProgressData,
    $$CachedProgressTableFilterComposer,
    $$CachedProgressTableOrderingComposer,
    $$CachedProgressTableAnnotationComposer,
    $$CachedProgressTableCreateCompanionBuilder,
    $$CachedProgressTableUpdateCompanionBuilder,
    (
      CachedProgressData,
      BaseReferences<_$AppDatabase, $CachedProgressTable, CachedProgressData>
    ),
    CachedProgressData,
    PrefetchHooks Function()> {
  $$CachedProgressTableTableManager(
      _$AppDatabase db, $CachedProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<int> bookId = const Value.absent(),
            Value<int> chapterNumber = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<DateTime?> readAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedProgressCompanion(
            userId: userId,
            bookId: bookId,
            chapterNumber: chapterNumber,
            isRead: isRead,
            readAt: readAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            required int bookId,
            required int chapterNumber,
            Value<bool> isRead = const Value.absent(),
            Value<DateTime?> readAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedProgressCompanion.insert(
            userId: userId,
            bookId: bookId,
            chapterNumber: chapterNumber,
            isRead: isRead,
            readAt: readAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedProgressTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedProgressTable,
    CachedProgressData,
    $$CachedProgressTableFilterComposer,
    $$CachedProgressTableOrderingComposer,
    $$CachedProgressTableAnnotationComposer,
    $$CachedProgressTableCreateCompanionBuilder,
    $$CachedProgressTableUpdateCompanionBuilder,
    (
      CachedProgressData,
      BaseReferences<_$AppDatabase, $CachedProgressTable, CachedProgressData>
    ),
    CachedProgressData,
    PrefetchHooks Function()>;
typedef $$OfflineWriteQueueTableCreateCompanionBuilder
    = OfflineWriteQueueCompanion Function({
  Value<int> id,
  required String type,
  required int bookId,
  Value<int?> chapterNumber,
  Value<bool?> isRead,
  Value<int?> totalChapters,
  Value<DateTime> createdAt,
});
typedef $$OfflineWriteQueueTableUpdateCompanionBuilder
    = OfflineWriteQueueCompanion Function({
  Value<int> id,
  Value<String> type,
  Value<int> bookId,
  Value<int?> chapterNumber,
  Value<bool?> isRead,
  Value<int?> totalChapters,
  Value<DateTime> createdAt,
});

class $$OfflineWriteQueueTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineWriteQueueTable> {
  $$OfflineWriteQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalChapters => $composableBuilder(
      column: $table.totalChapters, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OfflineWriteQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineWriteQueueTable> {
  $$OfflineWriteQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalChapters => $composableBuilder(
      column: $table.totalChapters,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OfflineWriteQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineWriteQueueTable> {
  $$OfflineWriteQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<int> get totalChapters => $composableBuilder(
      column: $table.totalChapters, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OfflineWriteQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineWriteQueueTable,
    OfflineWriteQueueData,
    $$OfflineWriteQueueTableFilterComposer,
    $$OfflineWriteQueueTableOrderingComposer,
    $$OfflineWriteQueueTableAnnotationComposer,
    $$OfflineWriteQueueTableCreateCompanionBuilder,
    $$OfflineWriteQueueTableUpdateCompanionBuilder,
    (
      OfflineWriteQueueData,
      BaseReferences<_$AppDatabase, $OfflineWriteQueueTable,
          OfflineWriteQueueData>
    ),
    OfflineWriteQueueData,
    PrefetchHooks Function()> {
  $$OfflineWriteQueueTableTableManager(
      _$AppDatabase db, $OfflineWriteQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineWriteQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineWriteQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineWriteQueueTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> bookId = const Value.absent(),
            Value<int?> chapterNumber = const Value.absent(),
            Value<bool?> isRead = const Value.absent(),
            Value<int?> totalChapters = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OfflineWriteQueueCompanion(
            id: id,
            type: type,
            bookId: bookId,
            chapterNumber: chapterNumber,
            isRead: isRead,
            totalChapters: totalChapters,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String type,
            required int bookId,
            Value<int?> chapterNumber = const Value.absent(),
            Value<bool?> isRead = const Value.absent(),
            Value<int?> totalChapters = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OfflineWriteQueueCompanion.insert(
            id: id,
            type: type,
            bookId: bookId,
            chapterNumber: chapterNumber,
            isRead: isRead,
            totalChapters: totalChapters,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineWriteQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OfflineWriteQueueTable,
    OfflineWriteQueueData,
    $$OfflineWriteQueueTableFilterComposer,
    $$OfflineWriteQueueTableOrderingComposer,
    $$OfflineWriteQueueTableAnnotationComposer,
    $$OfflineWriteQueueTableCreateCompanionBuilder,
    $$OfflineWriteQueueTableUpdateCompanionBuilder,
    (
      OfflineWriteQueueData,
      BaseReferences<_$AppDatabase, $OfflineWriteQueueTable,
          OfflineWriteQueueData>
    ),
    OfflineWriteQueueData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedProgressTableTableManager get cachedProgress =>
      $$CachedProgressTableTableManager(_db, _db.cachedProgress);
  $$OfflineWriteQueueTableTableManager get offlineWriteQueue =>
      $$OfflineWriteQueueTableTableManager(_db, _db.offlineWriteQueue);
}
