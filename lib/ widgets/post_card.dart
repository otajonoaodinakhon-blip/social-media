import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:fluttertoast/fluttertoast.dart';
import '../models/post.dart';
import '../services/firestore_service.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String currentUserId;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FirestoreService _firestore = FirestoreService();
  bool _isLiked = false;
  int _likeCount = 0;
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.likes.contains(widget.currentUserId);
    _likeCount = widget.post.likes.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: widget.post.userAvatar != null
                    ? CachedNetworkImageProvider(widget.post.userAvatar!)
                    : const NetworkImage(
                        'https://ui-avatars.com/api/?name=User&background=FF7A00&color=fff&size=100'
                      ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        timeago.format(widget.post.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Image
          if (widget.post.imageUrl != null)
            CachedNetworkImage(
              imageUrl: widget.post.imageUrl!,
              height: 350,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 350,
                color: Colors.grey[900],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 350,
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),

          // Caption
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.caption,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 8),
                
                // Like & Comments
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.white,
                        size: 28,
                      ),
                      onPressed: _toggleLike,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_likeCount',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.white, size: 26),
                      onPressed: _showComments,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.post.comments.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_border, color: Colors.white),
                      onPressed: () {},
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

  void _toggleLike() async {
    if (_isLiked) {
      _likeCount--;
      await _firestore.unlikePost(widget.post.id, widget.currentUserId);
    } else {
      _likeCount++;
      await _firestore.likePost(widget.post.id, widget.currentUserId);
    }
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Comments',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: widget.post.comments.isEmpty
                ? const Center(
                    child: Text(
                      'No comments yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.post.comments.length,
                    itemBuilder: (context, index) {
                      final comment = widget.post.comments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://ui-avatars.com/api/?name=${comment.username}&background=FF7A00&color=fff&size=100'
                          ),
                        ),
                        title: Text(
                          comment.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          comment.text,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    },
                  ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF7A00)),
                  onPressed: _addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addComment() async {
    if (_commentController.text.isEmpty) return;
    
    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.currentUserId,
      username: 'user', // Should get from auth
      text: _commentController.text,
      createdAt: DateTime.now(),
    );
    
    await _firestore.addComment(widget.post.id, comment);
    _commentController.clear();
    Fluttertoast.showToast(msg: 'Comment added!');
    Navigator.pop(context);
  }
}
