import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.user!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: () => _pickAvatar(context, auth),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: user.avatar != null
                  ? NetworkImage(user.avatar!)
                  : const NetworkImage(
                      'https://ui-avatars.com/api/?name=User&background=FF7A00&color=fff&size=200'
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              user.bio ?? 'Anime | Manga | Lifestyle',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              user.location ?? 'Tokyo, Japan',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('Posts', '86'),
                _buildStat('Followers', '${user.followers.length}'),
                _buildStat('Following', '${user.following.length}'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _editProfile(context, auth),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A00),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF7A00)),
                    ),
                    child: const Text('Share Profile'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Logout
            OutlinedButton(
              onPressed: () => auth.logout(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
              ),
              child: const Text('Log Out'),
            ),
            
            const SizedBox(height: 20),
            
            // Post Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return Container(
                  color: const Color(0xFF2A2A2E),
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.grey),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  void _editProfile(BuildContext context, AuthService auth) {
    final bioController = TextEditingController(text: auth.user?.bio ?? '');
    final locationController = TextEditingController(text: auth.user?.location ?? '');
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Bio',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF1A1A1A),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Location',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF1A1A1A),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await auth.updateProfile(
                  bio: bioController.text,
                  location: locationController.text,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickAvatar(BuildContext context, AuthService auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFFF7A00)),
              title: const Text('Gallery', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  final storage = StorageService();
                  final url = await storage.uploadImage(
                    File(image.path),
                    'avatars/${auth.user!.uid}',
                  );
                  if (url != null) {
                    await auth.updateProfile(avatar: url);
                  }
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFFF7A00)),
              title: const Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  final storage = StorageService();
                  final url = await storage.uploadImage(
                    File(image.path),
                    'avatars/${auth.user!.uid}',
                  );
                  if (url != null) {
                    await auth.updateProfile(avatar: url);
                  }
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
