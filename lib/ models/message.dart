class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.imageUrl,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }

  // Chat xonalarini yaratish uchun
  static String getChatRoomId(String userId1, String userId2) {
    // Ikkala ID ni tartiblab, birlashtiramiz
    List<String> ids = [userId1, userId2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }
}
