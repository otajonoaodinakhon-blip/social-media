class Post {
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String? imageUrl;
  final String caption;
  final List<String> likes;
  final List<Comment> comments;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    this.imageUrl,
    required this.caption,
    this.likes = const [],
    this.comments = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'imageUrl': imageUrl,
      'caption': caption,
      'likes': likes,
      'comments': comments.map((c) => c.toMap()).toList(),
      'createdAt': createdAt,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userAvatar: map['userAvatar'],
      imageUrl: map['imageUrl'],
      caption: map['caption'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      comments: (map['comments'] as List?)
              ?.map((c) => Comment.fromMap(c))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String username;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'text': text,
      'createdAt': createdAt,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }
}
