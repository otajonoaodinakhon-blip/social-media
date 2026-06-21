import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotification('nartuo_uz started following you.', '5m'),
          _buildNotification('anime.moments liked your post.', '15m'),
          _buildNotification('daily.inspiration commented: "Nice!"', '2h'),
          _buildNotification('Tokyo_Japan liked your post.', '15m'),
          _buildNotification('naruto_luz started following you.', '2h'),
        ],
      ),
    );
  }

  Widget _buildNotification(String text, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFF7A00),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFFF7A00),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.circle, size: 8, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
