import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // POSTS
  Future<void> createPost(Post post) async {
    await _firestore.collection('posts').doc(post.id).set(post.toMap());
  }

  Stream<List<Post>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Post.fromMap(doc.data());
          }).toList();
        });
  }

  Future<void> likePost(String postId, String userId) async {
    await _firestore.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> unlikePost(String postId, String userId) async {
    await _firestore.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> addComment(String postId, Comment comment) async {
    final doc = await _firestore.collection('posts').doc(postId).get();
    List<Map<String, dynamic>> comments = List.from(doc.data()?['comments'] ?? []);
    comments.add(comment.toMap());
    await _firestore.collection('posts').doc(postId).update({
      'comments': comments,
    });
  }

  // USERS
  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<AppUser?> streamUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!);
      }
      return null;
    });
  }

  Future<List<AppUser>> searchUsers(String query) async {
    final snapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: query + 'z')
        .limit(20)
        .get();
    
    return snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
  }
}
