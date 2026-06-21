import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/post.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _imageFile == null || _isUploading ? null : _uploadPost,
            child: Text(
              _isUploading ? 'Uploading...' : 'Share',
              style: TextStyle(
                color: _imageFile == null ? Colors.grey : const Color(0xFFFF7A00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2E),
                  borderRadius: BorderRadius.circular(12),
                  image: _imageFile != null
                    ? DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
                ),
                child: _imageFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 60,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to add photo',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    )
                  : null,
              ),
            ),
            const SizedBox(height: 16),
            
            // Caption
            TextField(
              controller: _captionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF2A2A2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _uploadPost() async {
    if (_imageFile == null) return;
    
    setState(() => _isUploading = true);
    
    final auth = Provider.of<AuthService>(context, listen: false);
    final storage = StorageService();
    final firestore = FirestoreService();
    
    try {
      // Upload image
      final imageUrl = await storage.uploadImage(
        _imageFile!,
        'posts/${auth.user!.uid}',
      );
      
      if (imageUrl == null) {
        setState(() => _isUploading = false);
        return;
      }
      
      // Create post
      final post = Post(
        id: const Uuid().v4(),
        userId: auth.user!.uid,
        username: auth.user!.username,
        userAvatar: auth.user!.avatar,
        imageUrl: imageUrl,
        caption: _captionController.text,
        likes: [],
        comments: [],
        createdAt: DateTime.now(),
      );
      
      await firestore.createPost(post);
      
      setState(() => _isUploading = false);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post shared! 🎉')),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
