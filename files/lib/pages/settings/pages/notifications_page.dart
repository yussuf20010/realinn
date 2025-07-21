import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NotificationCard(
            message: 'Your room booking in Heden golf has been successful',
            date: '20 July 2019',
          ),
          _NotificationCard(
            message: 'Message from the app admin',
            date: '20 July 2019',
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String message;
  final String date;
  const _NotificationCard({required this.message, required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
} 