class ReadingProgress {
  final String userId;
  final int bookId;
  final int chapterNumber;
  final bool isRead;
  final DateTime? readAt;

  ReadingProgress({
    required this.userId,
    required this.bookId,
    required this.chapterNumber,
    this.isRead = false,
    this.readAt,
  });

  // Factory to convert JSON from Supabase to Dart Object
  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      userId: json['user_id'] as String,
      bookId: json['book_id'] as int,
      chapterNumber: json['chapter_number'] as int,
      isRead: json['is_read'] as bool,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }
}