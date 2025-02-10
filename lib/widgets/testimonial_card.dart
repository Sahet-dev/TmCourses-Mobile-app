import 'package:flutter/material.dart';

class TestimonialCard extends StatelessWidget {
  final String text;
  final String author;

  const TestimonialCard({super.key, required this.text, required this.author});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 5),
            Text(
              author,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
