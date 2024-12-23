import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class CommentsScreen extends StatefulWidget {
  final String slug; // Slug của bài viết (blogSlug)
  final String title; // Tiêu đề bài viết

  const CommentsScreen({required this.slug, required this.title});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  bool isLoading = true;
  List<dynamic> comments = [];
  TextEditingController _commentController = TextEditingController();

  String? userId;
  String? firstName;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    fetchComments();
    loadUserInfo();
  }

  // Tải thông tin người dùng từ token
  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      setState(() {
        userId = decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
        firstName = decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname'];
        avatarUrl = decodedToken['AvatarUrl'];
      });
    }
  }

  // Gửi API để lấy danh sách bình luận
  Future<void> fetchComments() async {
    final String url =
        'https://doancoso220241205230136.azurewebsites.net/api/Products/${widget.slug}/comments';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          comments = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      print("Error fetching comments: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Gửi bình luận lên backend
  Future<void> submitComment(String content) async {
    if (content.isEmpty || userId == null || firstName == null || avatarUrl == null) {
      return; // Không gửi nếu thiếu thông tin
    }

    final String url =
        'https://doancoso220241205230136.azurewebsites.net/api/Products/${widget.slug}/comments';
    final Map<String, dynamic> body = {
      "userId": userId,
      "firstName": firstName,
      "avatarUrl": avatarUrl,
      "content": content,
      "createdAt": DateTime.now().toIso8601String(),
      "blogSlug": widget.slug
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _commentController.clear();
        fetchComments(); // Làm mới danh sách bình luận sau khi gửi
      } else {
        throw Exception('Failed to submit comment');
      }
    } catch (e) {
      print("Error submitting comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0, // Ngăn không cho AppBar thay đổi màu khi cuộn
        surfaceTintColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bình luận'),

          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
          : Column(
        children: [
          // Tiêu đề và số lượng bình luận
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bình luận bài viết",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis, // Thêm dấu "..." nếu nội dung quá dài
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${comments.length} bình luận",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ),
          Divider(height: 1, color: Colors.grey.shade300),

          // Tùy chọn "Xếp theo"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("Xếp theo", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    SizedBox(width: 4),
                    DropdownButton<String>(
                      value: "Hot nhất",
                      items: <String>["Hot nhất", "Mới nhất", "Cũ nhất"]
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        // Xử lý khi thay đổi thứ tự sắp xếp
                        print("Xếp theo: $newValue");
                      },
                      underline: SizedBox(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade300),

          // Danh sách bình luận
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          comment['avatarUrl'] ?? 'https://via.placeholder.com/50',
                        ),
                        radius: 24,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment['firstName'] ?? 'Không rõ tên',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatTime(comment['createdAt']),
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              comment['content'] ?? 'Không có nội dung',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Hộp nhập bình luận
          Divider(height: 1, color: Colors.grey.shade300),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              right: 5.0,
              bottom: 33.0,
              left: 10.0,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl ?? 'https://via.placeholder.com/50'),
                  radius: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Cảm nghĩ của bạn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.teal),
                  onPressed: () {
                    submitComment(_commentController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }

  String _formatTime(String? createdAt) {
    if (createdAt == null) return '';
    final DateTime dateTime = DateTime.parse(createdAt);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}
