import 'package:flutter/material.dart';
import 'detail_page.dart';

class DetailedPostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const DetailedPostCard({required this.post});

  @override
  _DetailedPostCardState createState() => _DetailedPostCardState();
}

class _DetailedPostCardState extends State<DetailedPostCard> {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5.0), // Độ bo góc
            child: Image.network(
              widget.post['imageUrl'],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.post['category']} | 8 phút đọc',
                      style: TextStyle(fontSize: 12, color: Colors.black),
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
                Text(
                  widget.post['title'],
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                if (widget.post['subtitle'] != null)
                  Text(
                    widget.post['subtitle'],
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                SizedBox(height: 8.0),
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
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined, size: 20, color: Colors.black),
                        SizedBox(width: 4.0),
                        Text('${widget.post['reactions']}'),
                        SizedBox(width: 16.0),
                        Icon(Icons.chat_bubble_outline, size: 20, color: Colors.black),
                        SizedBox(width: 4.0),
                        Text('${widget.post['comments']}'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
