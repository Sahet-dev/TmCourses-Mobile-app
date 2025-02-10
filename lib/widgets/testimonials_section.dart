import 'package:flutter/material.dart';
import 'package:course/widgets/testimonial_card.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What Our Learners Say",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          TestimonialCard(
            text: "This platform helped me land my dream job!",
            author: "John Doe",
          ),
          TestimonialCard(
            text: "I love how flexible the courses are!",
            author: "Jane Smith",
          ),
          SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text("See More Testimonials"),
            ),
          ),
        ],
      ),
    );
  }
}
