import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/reading_history.dart';
import '../common/appbar.dart';
import 'post.dart';

class ReadingHistory extends StatefulWidget {
  const ReadingHistory({super.key});

  @override
  State<ReadingHistory> createState() => _ReadingHistoryState();
}

class _ReadingHistoryState extends State<ReadingHistory> {
  late Future<List<ReadingHistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ReadingHistoryService.getHistory();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Reading History'),
        content:
            const Text('Are you sure you want to clear your reading history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ReadingHistoryService.clearHistory();
      setState(() {
        _historyFuture = ReadingHistoryService.getHistory();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: 'Reading History'),
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<List<ReadingHistoryEntry>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xfff7770f)),
            );
          }
          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 56.0, color: Colors.grey[300]),
                  const SizedBox(height: 12.0),
                  Text(
                    'No reading history yet',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Articles you read will appear here.',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              // Clear history button
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${history.length} article${history.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[500],
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearHistory,
                      child: const Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xfff7770f),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Post(
                            postid: entry.postId,
                            posttitle: entry.title,
                          ),
                        ),
                      ).then((_) {
                        setState(() {
                          _historyFuture = ReadingHistoryService.getHistory();
                        });
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 6.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: CachedNetworkImage(
                                imageUrl: entry.thumbnailUrl,
                                width: 75.0,
                                height: 75.0,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 75.0,
                                  height: 75.0,
                                  color: Colors.orange[50],
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 75.0,
                                  height: 75.0,
                                  color: Colors.orange[50],
                                  child: const Icon(Icons.image,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.title,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6.0),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 13.0,
                                          color: Colors.grey[400]),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        _timeAgo(entry.viewedAt),
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios,
                                size: 14.0, color: Colors.grey[300]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
