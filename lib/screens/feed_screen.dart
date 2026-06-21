import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import '../widgets/bottom_nav.dart';
import 'profile_screen.dart';
import 'create_post_screen.dart';
import 'chat_screen.dart';
import 'notifications_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _currentIndex = 0;
  final FirestoreService _firestore = FirestoreService();

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const FeedPage(),
      const ReelsPage(),
      const CreatePostScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreatePostScreen()),
            );
            return;
          }
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'uz.anime',
              style: TextStyle(
                color: Color(0xFFFF7A00),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stories
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFF7A00),
                            width: 3,
                          ),
                          image: DecorationImage(
                            image: index == 0
                              ? const NetworkImage(
                                  'https://ui-avatars.com/api/?name=Your+Story&background=FF7A00&color=fff&size=100'
                                )
                              : const NetworkImage(
                                  'https://ui-avatars.com/api/?name=Anime+User&background=2A2A2E&color=fff&size=100'
                                ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        index == 0 ? 'Your Story' : 'user_${index}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Posts
          Expanded(
            child: StreamBuilder<List<Post>>(
              stream: firestore.getPosts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No posts yet. Create one!'),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final post = snapshot.data![index];
                    return PostCard(
                      post: post,
                      currentUserId: auth.user!.uid,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Reels Coming Soon!',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
