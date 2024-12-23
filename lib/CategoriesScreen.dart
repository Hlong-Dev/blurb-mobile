import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<dynamic> _categories = [];
  List<dynamic> _posts = [];
  bool _isLoadingCategories = true;
  bool _isLoadingPosts = true;
  int _selectedIndex = 0;
  String? avatarUrl; // URL của avatar
  bool isLoggedIn = false; // Trạng thái đăng nhập
  final DraggableScrollableController _controller = DraggableScrollableController();


  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('https://doancoso220241205230136.azurewebsites.net/api/Category'));
      if (response.statusCode == 200) {
        setState(() {
          _categories = json.decode(response.body);
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      print('Error fetching categories: $e');
    }
  }
  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null) {
      // Giải mã JWT token
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
    try {
      final response = await http.get(Uri.parse('https://doancoso220241205230136.azurewebsites.net/api/Products/popular'));
      if (response.statusCode == 200) {
        setState(() {
          _posts = json.decode(response.body);
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingPosts = false);
      print('Error fetching posts: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchPosts();
    loadUserInfo();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Nếu tab Chủ đề được chọn (index 1), mở rộng danh sách
    if (index == 1) {
      _controller.animateTo(
        0.7,  // Mở rộng đến 70% màn hình
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Quan điểm - Tranh Luận',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Làm cho text in đậm
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        scrolledUnderElevation: 0, // Ngăn không cho AppBar thay đổi màu khi cuộn
        surfaceTintColor: Colors.white, // Đảm bảo màu nền luôn trắng
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          _isLoadingPosts
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(

              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bởi ${post['firstName'] ?? 'Unknown'}',
                                    style: TextStyle(fontSize: 12, color: Colors.black),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    post['title'],
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    post['imageUrl'] ?? 'https://via.placeholder.com/150',
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.remove_red_eye_outlined, size: 20, color: Colors.black),
                                    SizedBox(width: 4.0),
                                    Text('${post['viewCount'] ?? 0}', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                SizedBox(width: 16.0),
                                Row(
                                  children: [
                                    Icon(Icons.comment_outlined, size: 20, color: Colors.black),
                                    SizedBox(width: 4.0),
                                    Text('${post['comments'] ?? 0}', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.bookmark_border),
                              constraints: BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                print('Saved post: ${post['title']}');
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 0.3,
                          height: 0.5,
                        ),
                      ],
                    ),
                  ),
                );
              }

          ),
          DraggableScrollableSheet(
            controller: _controller,
            initialChildSize: 0.5, // Kích thước khởi đầu (40% màn hình)
            minChildSize: 0.1, // Kích thước nhỏ nhất (20% màn hình)
            maxChildSize: 0.95, // Kích thước lớn nhất (95% màn hình)
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Thanh kéo
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Tiêu đề
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      child: Text(
                        'Các chủ đề',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Danh sách chủ đề
                    Expanded(
                      child: _isLoadingCategories
                          ? Center(child: CircularProgressIndicator())
                          : ListView.builder(
                        controller: scrollController, // Gắn đúng scrollController
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _categories[index]['name']
                                  .toString()
                                  .toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            trailing: Icon(Icons.bookmark_border),
                            onTap: () {
                              // Xử lý khi chọn chủ đề
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),


        ],
      ),

    );
  }
}