import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/apis.dart';
import '../../models/user.dart';
import '../../models/bookmarks.dart';
import '../../models/reading_history.dart';
import '../common/appbar.dart';
import '../common/bottombar.dart';
import 'login.dart';
import 'disclaimer.dart';

class Post extends StatefulWidget {
  const Post({super.key, required this.postid, required this.posttitle});
  final int postid;
  final String posttitle;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  late int postid;
  late String posttitle;
  late Future<dynamic> postFuture;
  bool likedIcon = false;
  bool _isBookmarked = false;
  String likesCount = '0';
  String? _postLink;
  double _fontSize = 16.0;
  bool _historyRecorded = false;

  // Comments state
  final List<Map<String, dynamic>> _comments = [];
  bool _loadingComments = false;
  bool _hasMoreComments = true;
  int _commentsPage = 1;
  String _commentsCount = '0';
  bool _commentsCountInitialized = false;
  final TextEditingController _commentController = TextEditingController();
  bool _postingComment = false;
  final Set<int> _blockedUserIds = {};

  @override
  void initState() {
    super.initState();
    postid = widget.postid;
    posttitle = widget.posttitle;
    postFuture = fetchpost();
    _checkIfLiked();
    _checkBookmark();
    _loadBlockedThenComments();
    _loadFontSize();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<dynamic> fetchpost() async {
    final String postApiUrl = postApi + postid.toString();
    final response = await http.get(Uri.parse(postApiUrl));

    if (response.statusCode == 200) {
      final post = json.decode(response.body);
      return post;
    } else {
      throw Exception(
        'Failed to fetch post. Status code: ${response.statusCode}',
      );
    }
  }

  Future<void> _checkIfLiked() async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn || userState.token == null) return;

    try {
      final response = await http.get(
        Uri.parse(likedCheckApi(postid)),
        headers: {'Authorization': 'Bearer ${userState.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            likedIcon = data['liked'] == true;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _checkBookmark() async {
    final bookmarked = await BookmarkService.isBookmarked(postid);
    if (mounted) {
      setState(() {
        _isBookmarked = bookmarked;
      });
    }
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble('post_font_size');
    if (saved != null && mounted) {
      setState(() {
        _fontSize = saved;
      });
    }
  }

  Future<void> _saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('post_font_size', size);
  }

  Future<void> _toggleLike() async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to like posts.'),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
            ),
          ),
        ),
      );
      return;
    }

    // Optimistic update
    final wasLiked = likedIcon;
    final previousCount = likesCount;
    final currentCount = int.tryParse(likesCount) ?? 0;

    setState(() {
      likedIcon = !wasLiked;
      likesCount = wasLiked ? '${currentCount > 0 ? currentCount - 1 : 0}' : '${currentCount + 1}';
    });

    try {
      final url = likeApi(postid);
      final headers = {
        'Authorization': 'Bearer ${userState.token}',
        'Content-Type': 'application/json',
      };

      http.Response response;
      if (wasLiked) {
        response = await http.delete(Uri.parse(url), headers: headers);
      } else {
        response = await http.post(Uri.parse(url), headers: headers);
      }

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          likesCount = data['likes'] ?? likesCount;
        });
      } else {
        // Revert on failure
        setState(() {
          likedIcon = wasLiked;
          likesCount = previousCount;
        });
      }
    } catch (_) {
      if (!mounted) return;
      // Revert on error
      setState(() {
        likedIcon = wasLiked;
        likesCount = previousCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update like. Please try again.')),
      );
    }
  }

  Future<void> _toggleBookmark() async {
    await BookmarkService.toggleBookmark(postid);
    final bookmarked = await BookmarkService.isBookmarked(postid);
    if (mounted) {
      setState(() {
        _isBookmarked = bookmarked;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookmarked ? 'Bookmarked' : 'Removed from bookmarks'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _sharePost(BuildContext context) {
    final url = _postLink ?? '$baseUrl/?p=$postid';
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      '$posttitle\n$url',
      sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : Rect.zero,
    );
  }

  Future<void> _loadBlockedThenComments() async {
    await _loadBlockedUsers();
    _loadComments();
  }

  // Comments methods
  Future<void> _loadComments() async {
    if (_loadingComments || !_hasMoreComments) return;

    setState(() {
      _loadingComments = true;
    });

    try {
      final response = await http.get(
        Uri.parse(commentsApi(postid, page: _commentsPage)),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          for (final comment in data) {
            final authorId = comment['author'] as int? ?? 0;
            if (_blockedUserIds.contains(authorId)) continue;
            _comments.add({
              'id': comment['id'],
              'author_id': authorId,
              'author_name': comment['author_name'] ?? 'Anonymous',
              'avatar_url': comment['author_avatar_urls']?['48'] ?? '',
              'date': comment['date'] ?? '',
              'content': comment['content']?['rendered'] ?? '',
            });
          }
          _commentsPage++;
          _hasMoreComments = data.length >= 10;
          _loadingComments = false;
        });
      } else {
        setState(() {
          _loadingComments = false;
          _hasMoreComments = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingComments = false;
        });
      }
    }
  }

  Future<void> _postComment() async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to comment.'),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
            ),
          ),
        ),
      );
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _postingComment = true;
    });

    try {
      final response = await http.post(
        Uri.parse(addCommentApi(postid)),
        headers: {
          'Authorization': 'Bearer ${userState.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'content': content}),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final comment = data['comment'];
        final avatarUrls = comment['author_avatar_urls'];
        final avatarUrl = avatarUrls != null ? (avatarUrls['48'] ?? avatarUrls[48] ?? '') : '';
        final displayName = comment['author_name'] ?? '${userState.firstName ?? ''} ${userState.lastName ?? ''}'.trim();
        setState(() {
          _comments.insert(0, {
            'id': comment['id'],
            'author_id': userState.userId ?? 0,
            'author_name': displayName.isNotEmpty ? displayName : 'You',
            'avatar_url': avatarUrl.isNotEmpty ? avatarUrl : (userState.profileImageUrl ?? ''),
            'date': comment['date'] ?? DateTime.now().toIso8601String(),
            'content': comment['content']?['rendered'] ?? content,
          });
          _commentsCount = '${(int.tryParse(_commentsCount) ?? 0) + 1}';
          _postingComment = false;
        });
        _commentController.clear();
        FocusScope.of(context).unfocus();
      } else {
        setState(() {
          _postingComment = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post comment.')),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _postingComment = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error. Please try again.')),
        );
      }
    }
  }

  Future<void> _loadBlockedUsers() async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn || userState.token == null) return;

    try {
      final response = await http.get(
        Uri.parse(blockedUsersApi),
        headers: {'Authorization': 'Bearer ${userState.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> ids = data['blocked_user_ids'] ?? [];
        if (mounted) {
          setState(() {
            _blockedUserIds.addAll(ids.map((e) => e as int));
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _reportComment(int commentId) async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn) return;

    final reasons = ['Inappropriate content', 'Spam', 'Harassment', 'Misinformation', 'Other'];
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Report Comment'),
        children: reasons.map((r) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, r),
          child: Text(r, style: const TextStyle(fontSize: 15.0)),
        )).toList(),
      ),
    );

    if (reason == null || !mounted) return;

    try {
      final response = await http.post(
        Uri.parse(reportCommentApi(commentId)),
        headers: {
          'Authorization': 'Bearer ${userState.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reason': reason}),
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Comment reported.')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to report. Please try again.')),
        );
      }
    }
  }

  Future<void> _blockUser(int userId, String authorName) async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hide This User'),
        content: Text(
          'Hide comments from $authorName? Their comments will be removed from your feed. Our team will also be notified to review their content.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff7770f),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hide'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final response = await http.post(
        Uri.parse(blockUserApi(userId)),
        headers: {
          'Authorization': 'Bearer ${userState.token}',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _blockedUserIds.add(userId);
          final removedCount = _comments.where((c) => c['author_id'] == userId).length;
          _comments.removeWhere((c) => c['author_id'] == userId);
          final currentCount = int.tryParse(_commentsCount) ?? 0;
          _commentsCount = '${(currentCount - removedCount).clamp(0, currentCount)}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comments from $authorName are now hidden.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to block user. Please try again.')),
        );
      }
    }
  }

  Future<void> _editComment(int commentId, String currentContent) async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn) return;

    // Strip HTML tags for editing
    final plainText = currentContent.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    final controller = TextEditingController(text: plainText);

    final newContent = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Edit your comment...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff7770f),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (newContent == null || newContent.isEmpty || newContent == plainText) return;

    try {
      final response = await http.put(
        Uri.parse(editCommentApi(commentId)),
        headers: {
          'Authorization': 'Bearer ${userState.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'content': newContent}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          final index = _comments.indexWhere((c) => c['id'] == commentId);
          if (index != -1) {
            _comments[index]['content'] = '<p>$newContent</p>';
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment updated.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update comment. Please try again.')),
        );
      }
    }
  }

  Future<void> _deleteComment(int commentId) async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(
        Uri.parse(deleteCommentApi(commentId)),
        headers: {'Authorization': 'Bearer ${userState.token}'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _comments.removeWhere((c) => c['id'] == commentId);
          final currentCount = int.tryParse(_commentsCount) ?? 0;
          _commentsCount = '${(currentCount - 1).clamp(0, currentCount)}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete comment. Please try again.')),
        );
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      appBar: Appbar(title: widget.posttitle),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              FutureBuilder(
                future: postFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xfff7770f),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48.0, color: Color(0xfff7770f)),
                            const SizedBox(height: 16.0),
                            const Text(
                              'Unable to load content. Please check your connection and try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () => setState(() => postFuture = fetchpost()),
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Color(0xfff7770f)),
                                foregroundColor: WidgetStatePropertyAll(Colors.white),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    final post = snapshot.data;
                    // Store the canonical link for sharing
                    _postLink ??= post['link'];
                    // Set initial counts from post data (only if not yet modified by user)
                    if (likesCount == '0' && post['likes'] != null && post['likes'] != '0') {
                      likesCount = post['likes'];
                    }
                    if (!_commentsCountInitialized) {
                      _commentsCount = post['comments_count'] ?? '0';
                      _commentsCountInitialized = true;
                    }
                    final sources = post['sources'] ?? '';
                    // Record reading history once
                    if (!_historyRecorded) {
                      _historyRecorded = true;
                      ReadingHistoryService.addEntry(
                        postId: postid,
                        title: posttitle,
                        thumbnailUrl: post['featured_image_url'] ?? '',
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CachedNetworkImage(
                            imageUrl: post['featured_image_url'] ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 260.0,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xfff7770f),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                          // Font size controls
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Aa', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
                                const SizedBox(width: 8.0),
                                GestureDetector(
                                  onTap: () {
                                    if (_fontSize > 12.0) {
                                      setState(() {
                                        _fontSize -= 2.0;
                                      });
                                      _saveFontSize(_fontSize);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: const Icon(Icons.remove, size: 18.0, color: Color(0xfff7770f)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text(
                                    '${_fontSize.toInt()}',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (_fontSize < 24.0) {
                                      setState(() {
                                        _fontSize += 2.0;
                                      });
                                      _saveFontSize(_fontSize);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: const Icon(Icons.add, size: 18.0, color: Color(0xfff7770f)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Html(
                            data: post['content']['rendered'] ?? '',
                            style: {
                              'body': Style(
                                fontSize: FontSize(_fontSize),
                              ),
                              'p': Style(
                                fontSize: FontSize(_fontSize),
                                lineHeight: const LineHeight(1.6),
                              ),
                              'li': Style(
                                fontSize: FontSize(_fontSize),
                              ),
                              'h2': Style(
                                fontSize: FontSize(_fontSize + 6.0),
                              ),
                              'h3': Style(
                                fontSize: FontSize(_fontSize + 4.0),
                              ),
                            },
                          ),
                          // Source citation block
                          Container(
                              margin: const EdgeInsets.only(top: 10.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                border: const Border(
                                  left: BorderSide(
                                    color: Color(0xfff7770f),
                                    width: 4.0,
                                  ),
                                ),
                                color: Colors.orange[50],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.menu_book, size: 16.0, color: Colors.black87),
                                      SizedBox(width: 6.0),
                                      Text(
                                        'Sources & References',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    sources.isNotEmpty
                                        ? sources
                                        : 'Based on traditional Ayurvedic texts including Charaka Samhita, Sushruta Samhita, and Ashtanga Hridayam. For detailed references, consult the National Library of Ayurveda Medicine (NLAM).',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black54,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Medical disclaimer footer
                          Container(
                            margin: const EdgeInsets.only(top: 12.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.health_and_safety, size: 18.0, color: Colors.grey[500]),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const Disclaimer()),
                                    ),
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'For informational purposes only. Consult a healthcare professional before acting on any information. ',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.grey[600],
                                          height: 1.4,
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: 'Read full disclaimer',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Color(0xfff7770f),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          const Divider(
                            height: 2.0,
                            color: Colors.black26,
                          ),
                          const SizedBox(height: 15.0),
                          // Actions row
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _toggleLike,
                                    child: Row(
                                      children: [
                                        likedIcon
                                            ? const Icon(
                                                Icons.thumb_up,
                                                size: 28.0,
                                                color: Color(0xfff7770f),
                                              )
                                            : const Icon(
                                                Icons.thumb_up_alt_outlined,
                                                size: 28.0,
                                                color: Color(0xfff7770f),
                                              ),
                                        const SizedBox(width: 5.0),
                                        Text(
                                          likesCount,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20.0),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Row(
                                      children: [
                                        Text(
                                          post['dislikes'] ?? '0',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 5.0),
                                        const Icon(
                                          Icons.thumb_down_alt_outlined,
                                          size: 28.0,
                                          color: Color(0xfff7770f),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20.0),
                                  Builder(
                                    builder: (shareContext) => GestureDetector(
                                      onTap: () => _sharePost(shareContext),
                                      child: const Icon(
                                        Icons.share_outlined,
                                        size: 28.0,
                                        color: Color(0xfff7770f),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20.0),
                                  GestureDetector(
                                    onTap: _toggleBookmark,
                                    child: Icon(
                                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                      size: 28.0,
                                      color: const Color(0xfff7770f),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    _commentsCount,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    _commentsCount == '1' ? 'Comment' : 'Comments',
                                    style: const TextStyle(
                                      color: Color(0xfff7770f),
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          const Divider(height: 2.0, color: Colors.black12),
                          const SizedBox(height: 15.0),

                          // Comments section
                          const Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12.0),

                          // Comment input
                          if (userState.isLoggedIn)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    maxLines: 3,
                                    minLines: 1,
                                    decoration: InputDecoration(
                                      hintText: 'Write a comment...',
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: const BorderSide(color: Color(0xfff7770f)),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 10.0,
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 15.0),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                SizedBox(
                                  height: 44.0,
                                  child: ElevatedButton(
                                    onPressed: _postingComment ? null : _postComment,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xfff7770f),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    ),
                                    child: _postingComment
                                        ? const SizedBox(
                                            width: 18.0,
                                            height: 18.0,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.0,
                                            ),
                                          )
                                        : const Text('Post'),
                                  ),
                                ),
                              ],
                            )
                          else
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const Login()),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login, size: 18.0, color: Color(0xfff7770f)),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Log in to comment',
                                      style: TextStyle(
                                        color: Color(0xfff7770f),
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 15.0),

                          // Comments list
                          if (_comments.isEmpty && !_loadingComments)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(
                                child: Text(
                                  'No comments yet. Be the first to comment!',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ),

                          ..._comments.map((comment) {
                            final int commentAuthorId = comment['author_id'] ?? 0;
                            final bool isOwnComment = userState.isLoggedIn && commentAuthorId == userState.userId;
                            return Container(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16.0,
                                          backgroundColor: const Color(0xfff7770f),
                                          backgroundImage: (comment['avatar_url'] != null && (comment['avatar_url'] as String).isNotEmpty) ? NetworkImage(comment['avatar_url']) : null,
                                          child: (comment['avatar_url'] == null || (comment['avatar_url'] as String).isEmpty)
                                              ? Text(
                                                  (comment['author_name'] ?? 'A').substring(0, 1).toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 10.0),
                                        Expanded(
                                          child: Text(
                                            comment['author_name'] ?? 'Anonymous',
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatDate(comment['date'] ?? ''),
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        if (userState.isLoggedIn && commentAuthorId > 0)
                                          PopupMenuButton<String>(
                                            icon: Icon(Icons.more_vert, size: 18.0, color: Colors.grey[400]),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            itemBuilder: (_) => isOwnComment
                                                ? [
                                                    const PopupMenuItem(
                                                      value: 'edit',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.edit_outlined, size: 18.0, color: Colors.orange),
                                                          SizedBox(width: 8.0),
                                                          Text('Edit Comment'),
                                                        ],
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'delete',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.delete_outline, size: 18.0, color: Colors.red),
                                                          SizedBox(width: 8.0),
                                                          Text('Delete Comment'),
                                                        ],
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    const PopupMenuItem(
                                                      value: 'report',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.flag_outlined, size: 18.0, color: Colors.orange),
                                                          SizedBox(width: 8.0),
                                                          Text('Report Comment'),
                                                        ],
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'block',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.visibility_off, size: 18.0, color: Colors.red),
                                                          SizedBox(width: 8.0),
                                                          Text('Hide This User'),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _editComment(comment['id'] as int, comment['content'] ?? '');
                                              } else if (value == 'delete') {
                                                _deleteComment(comment['id'] as int);
                                              } else if (value == 'report') {
                                                _reportComment(comment['id'] as int);
                                              } else if (value == 'block') {
                                                _blockUser(commentAuthorId, comment['author_name'] ?? 'this user');
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6.0),
                                    Html(
                                      data: comment['content'] ?? '',
                                      style: {
                                        'body': Style(
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                          fontSize: FontSize(14.0),
                                          color: Colors.black87,
                                        ),
                                        'p': Style(
                                          margin: Margins.zero,
                                        ),
                                      },
                                    ),
                                  ],
                                ),
                              );
                          }),

                          // Loading indicator
                          if (_loadingComments)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xfff7770f),
                                ),
                              ),
                            ),

                          // Load more button
                          if (_hasMoreComments && !_loadingComments && _comments.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Center(
                                child: TextButton(
                                  onPressed: _loadComments,
                                  child: const Text(
                                    'Load more comments',
                                    style: TextStyle(
                                      color: Color(0xfff7770f),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 15.0),
                        ],
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Bottombar(currentIndex: 0),
    );
  }
}
