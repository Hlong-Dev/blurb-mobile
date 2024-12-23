import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'comments_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import "utils.dart";

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const DetailPage({required this.post});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isBookmarked = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkIfBookmarked(widget.post['slug']);
    sendViewCount(widget.post['slug']);
  }

  Future<void> sendViewCount(String slug) async {
    final String url =
        'https://doancoso220241205230136.azurewebsites.net/api/Products/' + slug;

    try {
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode != 200) {
        print("Lỗi khi gửi lượt xem: ${response.body}");
      }
    } catch (e) {
      print("Error sending view count: $e");
    }
  }

  Future<void> checkIfBookmarked(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print("Token không tồn tại");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String url =
        'https://doancoso220241205230136.azurewebsites.net/api/Products/check-saved/$slug';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isBookmarked = data['isSaved'] ?? false;
          isLoading = false;
        });
      } else {
        print("Lỗi khi kiểm tra trạng thái bookmark: ${response.body}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error checking bookmark status: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> toggleBookmark(BuildContext context, String slug) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print("Token không tồn tại");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng đăng nhập để lưu bài viết.")),
      );
      return;
    }

    final String url =
        'https://doancoso220241205230136.azurewebsites.net/api/Products/saved';

    final Map<String, dynamic> body = {
      "slug": slug,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isBookmarked = !isBookmarked;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBookmarked
                ? "Bài viết đã được lưu!"
                : "Bài viết đã được bỏ lưu!"),
          ),
        );
      } else {
        print("Lỗi khi lưu hoặc bỏ lưu bookmark: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không thể thay đổi trạng thái lưu bài viết.")),
        );
      }
    } catch (e) {
      print("Error toggling bookmark: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xảy ra lỗi khi thay đổi trạng thái lưu bài viết.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String content = widget.post['content'] ?? "<p>No content available</p>";

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(57),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              scrolledUnderElevation: 0,
              actions: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Theo dõi",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
            Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  widget.post['category']?.toUpperCase() ?? "Danh mục",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post['title'] ?? "Không có tiêu đề",
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      widget.post['description'] ?? "Không có mô tả",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        widget.post['avatarUrl'] ?? "https://via.placeholder.com/50",
                      ),
                      radius: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Bởi ${widget.post['author'] ?? "Không rõ"}",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Spacer(),
                    Text(
                      getTimeAgo(widget.post['createdAt']),
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Html(
                  data: content,
                  style: {
                    "body": Style(
                      fontSize: FontSize(17),
                      lineHeight: LineHeight(1.5),
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.justify,
                    ),
                    "img": Style(
                      width: Width(380, Unit.percent),
                      height: Height(310),// Chiều rộng 100% của container
                      alignment: Alignment.center,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 60),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                print("Vote up clicked!");
              },
              child: Row(
                children: [
                  Icon(Icons.arrow_drop_up, size: 24),
                  SizedBox(width: 4),
                  Text("9", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Vote down clicked!");
              },
              child: Icon(Icons.arrow_drop_down, size: 24),
            ),
            Container(
              height: 24,
              width: 1,
              color: Colors.grey.shade400,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommentsScreen(
                      slug: widget.post['slug'],
                      title: widget.post['title'],
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 24),
                  SizedBox(width: 4),
                  Text("0", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              height: 24,
              width: 1,
              color: Colors.grey.shade400,
            ),
            GestureDetector(
              onTap: () => toggleBookmark(context, widget.post['slug']),
              child: Icon(
                isBookmarked ? Icons.bookmark_added : Icons.bookmark_add_outlined,
                size: 24,
              ),
            ),
            Container(
              height: 24,
              width: 1,
              color: Colors.grey.shade400,
            ),
            GestureDetector(
              onTap: () {
                print("Share clicked!");
              },
              child: Icon(Icons.share_outlined, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
