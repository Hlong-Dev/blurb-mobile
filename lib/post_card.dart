import 'package:flutter/material.dart';
import 'detail_page.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({required this.post});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isBookmarked = false; // Biến trạng thái để theo dõi trạng thái bookmark

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(post: widget.post),
          ),
        );
      },
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
                      Row(
                        children: [
                          Text(
                            'Bởi ',
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: widget.post['avatarUrl'] != null
                                ? NetworkImage(widget.post['avatarUrl'])
                                : AssetImage('assets/default_avatar.png') as ImageProvider,
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            '${widget.post['author']}',
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        widget.post['title'],
                        style: TextStyle(
                          fontSize: 16,
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
                      borderRadius: BorderRadius.circular(5), // Điều chỉnh số này để thay đổi độ bo góc
                      child: Image.network(
                        widget.post['imageUrl'] ?? 'https://via.placeholder.com/150',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Phần reactions và nút lưu ngang hàng nhau
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined, size: 20, color: Colors.black),
                        SizedBox(width: 4.0),
                        Text('${widget.post['reactions']}', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    SizedBox(width: 16.0),
                    Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 20, color: Colors.black),
                        SizedBox(width: 4.0),
                        Text('${widget.post['comments']}', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
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
}
