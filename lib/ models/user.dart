class AppUser {
  final String uid;
  final String username;
  final String email;
  final String? avatar;
  final String? bio;
  final String? location;
  final List<String> followers;
  final List<String> following;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.username,
    required this.email,
    this.avatar,
    this.bio,
    this.location,
    this.followers = const [],
    this.following = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'avatar': avatar,
      'bio': bio,
      'location': location,
      'followers': followers,
      'following': following,
      'createdAt': createdAt,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      avatar: map['avatar'],
      bio: map['bio'],
      location: map['location'],
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      createdAt: (map['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }
}
