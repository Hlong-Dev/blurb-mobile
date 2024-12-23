import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'post_card.dart';
import 'detailed_post_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'popular_posts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> selectedTabPosts = [];
  bool isLoading = true;
  bool isTabLoading = false;
  String? avatarUrl;
  bool isSubscribed = false;
  bool isLoggedIn = false;
  final ScrollController _scrollController = ScrollController();
  String currentTab = 'popular';
  Set<String> loadedTabs = {}; // Lưu các tab đã tải dữ liệu

  @override
  void initState() {
    super.initState();
    fetchPosts();
    loadUserInfo();
    fetchTabPosts('popular');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      setState(() {
        avatarUrl = decodedToken['AvatarUrl'];
        isLoggedIn = true;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    setState(() {
      isLoggedIn = false;
      avatarUrl = null;
    });
  }

  Future<void> fetchPosts() async {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }


    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedPosts = prefs.getString('cached_posts');

      // Nếu có cache, sử dụng cache trước
      if (cachedPosts != null) {
        final List<dynamic> cachedData = json.decode(cachedPosts);
        setState(() {
          posts = cachedData.map((item) => Map<String, dynamic>.from(item)).toList();
          isLoading = false;
        });
      }

      // Gọi API để lấy dữ liệu mới
      final response = await http.get(
          Uri.parse('https://doancoso220241205230136.azurewebsites.net/api/Products'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        data.sort((a, b) {
          DateTime dateA = DateTime.parse(a['createdAt']);
          DateTime dateB = DateTime.parse(b['createdAt']);
          return dateB.compareTo(dateA); // Giảm dần
        });
        // Cập nhật dữ liệu và lưu vào cache
        await prefs.setString('cached_posts', json.encode(data));

        setState(() {
          posts = data.take(14).map((item) => {
            'slug': item['slug'],
            'avatarUrl': item['avatarUrl'],
            'title': item['title'],
            'author': item['firstName'],
            'imageUrl': item['imageUrl'],
            'reactions': item['viewCount'],
            'comments': 2,
            'description': item['description'],
            'category': item['categorySlug'],
            'subtitle': item['description'],
            'content': item['content'],
            'createdAt': item['createdAt'],
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }


  Future<void> fetchTabPosts(String tabType) async {
    setState(() {
      isTabLoading = true;
      currentTab = tabType;
    });

    try {
      // Xác định URL API dựa trên loại tab
      String apiUrl;
      switch (tabType) {
        case 'popular':
          apiUrl = 'https://doancoso220241205230136.azurewebsites.net/api/Products/popular';
          break;
        case 'new':
          apiUrl = 'https://doancoso220241205230136.azurewebsites.net/api/Products';
          break;
        case 'trending':
          apiUrl = 'https://doancoso220241205230136.azurewebsites.net/api/Products/popular';
          break;
        case 'top':
          apiUrl = 'https://doancoso220241205230136.azurewebsites.net/api/Products';
          break;
        default:
          apiUrl = 'https://doancoso220241205230136.azurewebsites.net/api/Products/popular';
      }

      // Gọi API để lấy dữ liệu mới
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Nếu là tab `new`, sắp xếp bài viết theo thời gian giảm dần
        if (tabType == 'new') {
          data.sort((a, b) {
            DateTime dateA = DateTime.parse(a['createdAt']);
            DateTime dateB = DateTime.parse(b['createdAt']);
            return dateB.compareTo(dateA); // Giảm dần
          });
        }

        setState(() {
          selectedTabPosts = data.map((item) => {
            'slug': item['slug'],
            'avatarUrl': item['avatarUrl'],
            'title': item['title'],
            'author': item['firstName'],
            'imageUrl': item['imageUrl'],
            'reactions': item['viewCount'],
            'comments': 2,
            'description': item['description'],
            'category': item['categorySlug'],
            'subtitle': item['description'],
            'content': item['content'],
            'createdAt': item['createdAt'],
          }).toList();
          isTabLoading = false;
        });
      } else {
        throw Exception('Failed to load $tabType posts');
      }
    } catch (e) {
      setState(() {
        isTabLoading = false;
      });
      print("Error fetching $tabType posts: $e");
    }
  }

  Widget _buildNavItem(String label, IconData icon, String tabType) {
    bool isSelected = currentTab == tabType;
    return InkWell(
      onTap: () {
        if (currentTab != tabType) {
          fetchTabPosts(tabType);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.teal : Colors.black54,
                size: 20,
              ),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.teal : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          if (isSelected)
            Container(
              height: 2,
              width: 80,
              color: Colors.teal,
              margin: EdgeInsets.only(top: 4),
            ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavItem('Thịnh hành', Icons.trending_up, 'popular'),
        _buildNavItem('Mới', Icons.new_releases_outlined, 'new'),
        _buildNavItem('Sôi nổi', Icons.forum_outlined, 'trending'),
        _buildNavItem('Top', Icons.flag_outlined, 'top'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.network(
              'https://i.imgur.com/rBkYKoG.png',
              height: 35,
              width: 35,
            ),
            Text(
              'Blurb',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          isLoggedIn
              ? GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Đăng xuất'),
                  content: Text('Bạn có chắc muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        logout();
                        Navigator.pop(ctx);
                      },
                      child: Text('Đăng xuất'),
                    ),
                  ],
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(8.0), // Tùy chỉnh khoảng cách
              child: CircleAvatar(
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
            ),
          )
              : IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              ).then((_) => loadUserInfo());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchPosts();
          await fetchTabPosts(currentTab);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đừng bỏ lỡ',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          if (posts.isNotEmpty)
                            DetailedPostCard(post: posts[13])
                          else
                            Text("Không có bài viết nào!"),
                          SizedBox(height: 16),
                        ],
                      );
                    } else if (index <= posts.length) {
                      // Hiển thị các bài viết còn lại
                      return PostCard(post: posts[index - 1]);
                    } else {
                      // Chèn thêm đoạn "Bài viết của tháng" vào cuối danh sách
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bài viết của tháng',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.space_dashboard_rounded, size: 24),
                                    onPressed: () {
                                      print('Filter clicked');
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.format_list_bulleted_rounded, size: 24),
                                    onPressed: () {
                                      print('More options clicked');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          PopularPosts(),
                        ],
                      );
                    }
                  },
                  childCount: posts.length + 2, // Thêm 2: 1 cho đoạn "Bài viết của tháng"
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://static1.eb-pages.com/uploads/5987363858153472/image.png',
                            width: 100,
                            height: 100,
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Những bài viết nổi bật bạn không nên bỏ lỡ',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Thứ Năm hàng tuần, bạn sẽ nhận được email từ Blurb với những bài viết đáng đọc nhất tuần qua.',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      if (!isSubscribed) // Hiển thị form nhập email khi chưa đăng ký
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Email của bạn',
                                  hintStyle: TextStyle(fontSize: 14.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  isSubscribed = true; // Cập nhật trạng thái khi đăng ký
                                });
                              },
                              child: Text(
                                'Đăng ký',
                                style: TextStyle(fontSize: 14.0, color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      else // Hiển thị thông báo khi đã đăng ký
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Center(
                            child: Text(
                              'Bạn đã đăng ký thành công',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),


            SliverPersistentHeader(
              pinned: true,
              delegate: NavBarDelegate(navBar: _buildNavBar()),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return PostCard(post: selectedTabPosts[index]);
                  },
                  childCount: selectedTabPosts.length,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class NavBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget navBar;

  NavBarDelegate({required this.navBar});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: overlapsContent
            ? [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ]
            : null,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: navBar,
    );
  }

  @override
  double get maxExtent => 50.0;

  @override
  double get minExtent => 50.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
