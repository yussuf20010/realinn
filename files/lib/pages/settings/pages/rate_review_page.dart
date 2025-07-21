import 'package:flutter/material.dart';

class RateReviewPage extends StatefulWidget {
  const RateReviewPage({Key? key}) : super(key: key);

  @override
  State<RateReviewPage> createState() => _RateReviewPageState();
}

class _RateReviewPageState extends State<RateReviewPage> {
  int selectedRating = 0;
  final TextEditingController _controller = TextEditingController();

  final List<String> emojis = [
    '😊', // very happy
    '🙂', // happy
    '😐', // neutral
    '😕', // sad
    '😟', // very sad
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Give rating & Review', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(emojis.length, (index) {
                return GestureDetector(
                  onTap: () => setState(() => selectedRating = index + 1),
                  child: CircleAvatar(
                    backgroundColor: selectedRating == index + 1 ? Colors.teal : Colors.grey[200],
                    radius: 28,
                    child: Text(emojis[index], style: const TextStyle(fontSize: 28)),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Write your review',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text('Submit', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 