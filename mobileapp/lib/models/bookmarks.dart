import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const _key = 'bookmarked_posts';

  static Future<List<int>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => int.parse(e)).toList();
  }

  static Future<bool> isBookmarked(int postId) async {
    final bookmarks = await getBookmarks();
    return bookmarks.contains(postId);
  }

  static Future<void> toggleBookmark(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    final idStr = postId.toString();
    if (list.contains(idStr)) {
      list.remove(idStr);
    } else {
      list.insert(0, idStr);
    }
    await prefs.setStringList(_key, list);
  }
}
