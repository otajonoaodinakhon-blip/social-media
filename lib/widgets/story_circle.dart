import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/story_circle.dart';
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

  // Demo stories
  final List<StoryData> _demoStories = [
    StoryData(
      userId: 'current_user',
      username: 'Your Story',
      userAvatar: '',
      createdAt: DateTime.now(),
      isViewed: false,
    ),
    StoryData(
      userId: 'user1',
      username: 'anime.moments',
      userAvatar: 'https://ui-avatars.com/api/?name=AM&background=FF7A00&color=fff&size=100',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isViewed: false,
    ),
    StoryData(
      userId: 'user2',
      username: 'naruto_luz',
      userAvatar: 'https://ui-avatars.com/api/?name=NL&background=FF7A00&color=fff&size=100',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isViewed: true,
    ),
    StoryData(
      userId: 'user3',
      username: 'daily.inspiration',
      userAvatar: 'https://ui-avatars.com/api/?name=DI&background=FF7A00&color=fff&size=100',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isViewed: false,
    ),
    StoryData(
      userId: 'user4',
      username: 'Tokyo_Japan',
      userAvatar: 'https://ui-avatars.com/api/?name=TJ&background=FF7A00&color=fff&size=100',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      isViewed: false,
    ),
    StoryData(
      userId: 'user5',
      username: 'animeworld',
      userAvatar: 'https://ui-avatars.com/api/?name=AW&background=FF7A00&color=fff&size=100',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isViewed: true,
    ),
    StoryData(
      userId: 'user6',
      username: 'izuchu_uchiha',
      userAvatar: 'https://ui-avatars.com/api/?name=IU&background=FF7A00&color=fff&size=100',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      isViewed: false,
    ),
  ];

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
          StoriesList(
            stories: (context as _FeedScreenState)._demoStories,
            currentUserId: auth.user!.uid,
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
                    child: Text(
                      'No posts yet. Create one!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🎬 Reels',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
