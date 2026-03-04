import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/apis.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../pages/categories.dart';
import '../pages/category_posts.dart';
import '../pages/disclaimer.dart';
import '../pages/post.dart';
import '../pages/search.dart';
import '../common/horizontalposts.dart';
import '../common/bottombar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<dynamic>> _recentPosts;
  late Future<List<dynamic>> _categories;
  late Future<Map<String, dynamic>?> _dailyTip;
  late Future<List<dynamic>> _recommendedPosts;

  @override
  void initState() {
    super.initState();
    _recentPosts = _fetchRecentPosts();
    _categories = _fetchCategories();
    _dailyTip = _fetchDailyTip();
    final userState = Provider.of<UserState>(context, listen: false);
    if (userState.isLoggedIn && userState.token != null) {
      _recommendedPosts = _fetchRecommendations(userState.token!);
    } else {
      _recommendedPosts = _fetchPopularPosts();
    }
  }

  Future<List<dynamic>> _fetchRecentPosts() async {
    final response = await http.get(
      Uri.parse('$postApi?per_page=10&orderby=date&order=desc'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  Future<List<dynamic>> _fetchCategories() async {
    final response = await http.get(
      Uri.parse('$categoriesApi?per_page=20&exclude=1,13'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  Future<Map<String, dynamic>?> _fetchDailyTip() async {
    try {
      final response = await http.get(Uri.parse(dailyTipApi));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (_) {}
    return null;
  }

  Future<List<dynamic>> _fetchRecommendations(String token) async {
    try {
      final response = await http.get(
        Uri.parse(recommendationsApi),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (_) {}
    return _fetchPopularPosts();
  }

  Future<List<dynamic>> _fetchPopularPosts() async {
    try {
      final response = await http.get(Uri.parse(popularPostsApi));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (_) {}
    return [];
  }

  String _timeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      width: 40.0,
                      height: 40.0,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10.0),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aayurveda',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Ayurvedic Health & Wellness',
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15.0),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Search()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[500]),
                        const SizedBox(width: 10.0),
                        Text(
                          'Search articles...',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),

              // Daily Health Tip
              FutureBuilder<Map<String, dynamic>?>(
                future: _dailyTip,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  final tip = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xfff7770f), Color(0xffff9a3c)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20.0),
                              const SizedBox(width: 8.0),
                              const Text(
                                'Daily Health Tip',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(50),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  tip['category'] ?? '',
                                  style: const TextStyle(fontSize: 11.0, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            tip['tip'] ?? '',
                            style: const TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Featured Articles
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Featured Articles',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Evidence-based articles with cited sources',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              FutureBuilder<List<dynamic>>(
                future: _recentPosts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 190.0,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xfff7770f),
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                    return const SizedBox(
                      height: 100.0,
                      child: Center(
                        child: Text(
                          'Unable to load articles.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: HorizontalPosts(
                      categoryName: '',
                      posts: snapshot.data,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10.0),

              // Recommended for You / Popular Articles
              FutureBuilder<List<dynamic>>(
                future: _recommendedPosts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  final posts = snapshot.data ?? [];
                  if (posts.isEmpty) return const SizedBox.shrink();
                  final userState = Provider.of<UserState>(context, listen: false);
                  final sectionTitle = userState.isLoggedIn ? 'Recommended for You' : 'Popular Articles';
                  // Show max 4 posts
                  final displayPosts = posts.length > 4 ? posts.sublist(0, 4) : posts;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          sectionTitle,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      ...displayPosts.map((post) {
                        final title = post['title']?['rendered'] ?? post['title'] ?? '';
                        final imageUrl = post['featured_image_url'] ?? '';
                        final postId = post['id'];
                        final date = post['date'] ?? '';
                        final likes = post['likes'] ?? '0';
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Post(postid: postId, posttitle: title),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: Colors.grey[200]!, width: 1.0),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    width: 75.0,
                                    height: 75.0,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(width: 75.0, height: 75.0, color: Colors.orange[50]),
                                    errorWidget: (_, __, ___) => Container(width: 75.0, height: 75.0, color: Colors.orange[50], child: const Icon(Icons.image, color: Colors.grey)),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
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
                                          Icon(Icons.access_time, size: 13.0, color: Colors.grey[400]),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            _timeAgo(date),
                                            style: TextStyle(fontSize: 12.0, color: Colors.grey[500]),
                                          ),
                                          const SizedBox(width: 12.0),
                                          Icon(Icons.thumb_up_outlined, size: 13.0, color: Colors.grey[400]),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            likes,
                                            style: TextStyle(fontSize: 12.0, color: Colors.grey[500]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 5.0),
                    ],
                  );
                },
              ),

              // Browse Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Browse Categories',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Categories()),
                      ),
                      child: const Text(
                        'See All',
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
              const SizedBox(height: 10.0),
              FutureBuilder<List<dynamic>>(
                future: _categories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 120.0,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xfff7770f),
                        ),
                      ),
                    );
                  }
                  final cats = snapshot.data ?? [];
                  if (cats.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemCount: cats.length,
                      itemBuilder: (context, index) {
                        final cat = cats[index];
                        final name = cat['name'] ?? '';
                        final imageUrl = cat['category_image_url'];
                        final iconUrl = cat['category_icon_url'];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryPosts(
                                categoryId: cat['id'],
                                categoryName: name,
                              ),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (imageUrl != null)
                                  CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(color: Colors.orange[50]),
                                    errorWidget: (_, __, ___) => Container(color: Colors.orange[50]),
                                  )
                                else
                                  Container(color: Colors.orange[50]),
                                Container(
                                  color: Colors.black.withAlpha(140),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (iconUrl != null)
                                      ColorFiltered(
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: iconUrl,
                                          width: 32.0,
                                          height: 32.0,
                                          fit: BoxFit.contain,
                                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                                        ),
                                      ),
                                    const SizedBox(height: 8.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Text(
                                        name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 15.0),

              // Disclaimer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.health_and_safety, size: 18.0, color: Colors.grey[700]),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Disclaimer()),
                          ),
                          child: Text.rich(
                            TextSpan(
                              text: 'Every article includes referenced sources from medical literature. Consult a healthcare professional before acting on any information. ',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Read full Medical Disclaimer',
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
              ),
              const SizedBox(height: 15.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Bottombar(currentIndex: 0),
    );
  }
}
