import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingHistoryEntry {
  final int postId;
  final String title;
  final String thumbnailUrl;
  final DateTime viewedAt;

  ReadingHistoryEntry({
    required this.postId,
    required this.title,
    required this.thumbnailUrl,
    required this.viewedAt,
  });

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'viewedAt': viewedAt.toIso8601String(),
      };

  factory ReadingHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ReadingHistoryEntry(
        postId: json['postId'],
        title: json['title'] ?? '',
        thumbnailUrl: json['thumbnailUrl'] ?? '',
        viewedAt: DateTime.parse(json['viewedAt']),
      );
}

class ReadingHistoryService {
  static const _key = 'reading_history';
  static const _maxEntries = 50;

  static Future<List<ReadingHistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    final List<dynamic> list = json.decode(jsonStr);
    return list.map((e) => ReadingHistoryEntry.fromJson(e)).toList();
  }

  static Future<void> addEntry({
    required int postId,
    required String title,
    required String thumbnailUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    // Remove existing entry for same post (moves it to top)
    history.removeWhere((e) => e.postId == postId);
    // Insert at beginning
    history.insert(
      0,
      ReadingHistoryEntry(
        postId: postId,
        title: title,
        thumbnailUrl: thumbnailUrl,
        viewedAt: DateTime.now(),
      ),
    );
    // Trim to max
    if (history.length > _maxEntries) {
      history.removeRange(_maxEntries, history.length);
    }
    await prefs.setString(
      _key,
      json.encode(history.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
