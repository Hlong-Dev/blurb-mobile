import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'detail_page.dart';

class PopularPosts extends StatefulWidget {
  @override
  _PopularPostsState createState() => _PopularPostsState();
}

class _PopularPostsState extends State<PopularPosts> {
  bool isBookmarked = false;
  List<Map<String, dynamic>> popularPosts = [];
  bool isLoading = true;
  final PageController _pageController = PageController(); // Controller cho PageView

  @override
  void initState() {
    super.initState();
    fetchPopularPosts();
  }

  Future<void> fetchPopularPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://doancoso220241205230136.azurewebsites.net/api/Products/popular'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          popularPosts = data.take(10).map((item) => {
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
        throw Exception('Failed to load popular posts');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420, // Chiều cao tổng thể
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: popularPosts.length,
              itemBuilder: (context, index) {
                final post = popularPosts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(post: post),
                      ),
                    );
                  },

                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hình ảnh bài viết
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post['imageUrl'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Category và phút đọc
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${post['category']} | 5 phút đọc',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark_added // Icon khi đã lưu
                                    : Icons.bookmark_add_outlined, // Icon khi chưa lưu
                              ),
                              onPressed: () {
                                setState(() {
                                  isBookmarked = !isBookmarked; // Đổi trạng thái
                                });
                              },
                            ),
                          ],
                        ),

                        // Tiêu đề bài viết
                        Text(
                          post['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        // Mô tả bài viết
                        Text(
                          post['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        // Tác giả, viewCount và comments
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Bởi ',
                                  style: TextStyle(fontSize: 12, color: Colors.black),
                                ),
                                CircleAvatar(
                                  radius: 12,
                                  backgroundImage: post['avatarUrl'] != null
                                      ? NetworkImage(post['avatarUrl'])
                                      : AssetImage('assets/default_avatar.png') as ImageProvider,
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  '${post['author']}',
                                  style: TextStyle(fontSize: 12, color: Colors.black),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text('${post['reactions']}'),
                                SizedBox(width: 16),
                                Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text('${post['comments']}'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          // SmoothPageIndicator
          SmoothPageIndicator(
            controller: _pageController,
            count: popularPosts.length,
            effect: WormEffect(
              dotHeight: 3,
              dotWidth: 16,
              activeDotColor: Colors.teal,
              dotColor: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
