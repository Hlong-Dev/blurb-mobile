import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'post_card.dart';


class SavedPostsScreen extends StatefulWidget {
  @override
  _SavedPostsScreenState createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  List<Map<String, dynamic>> savedPosts = [];
  bool isLoading = true;
  String? avatarUrl; // URL của avatar
  bool isLoggedIn = false; // Trạng thái đăng nhập
  @override
  void initState() {
    super.initState();
    fetchSavedPosts();
    loadUserInfo();
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
  Future<void> fetchSavedPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('https://doancoso220241205230136.azurewebsites.net/api/Products/saved'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          savedPosts = data.map((item) => {
            'title': item['title'],
            'avatarUrl': item['avatarUrl'],
            'author': item['firstName'],
            'imageUrl': item['imageUrl'],
            'reactions': item['viewCount'],
            'comments': 0,
            'description': item['description'],
            'category': item['categorySlug'],
            'subtitle': item['description'],
            'content': item['content'],
            'createdAt': item['createdAt'],
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load saved posts');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải bài viết đã lưu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Bài đã lưu',
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
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : savedPosts.isEmpty
          ? Center(child: Text('Chưa có bài viết nào được lưu'))
          : ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: savedPosts.length,
        itemBuilder: (context, index) {
          return PostCard(post: savedPosts[index]);
        },
      ),
    );
  }
}