// main_page.dart
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hero Section
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.black,
              child: Column(
                children: [
                  Text(
                    "Welcome to the Learning Platform",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Explore, Learn, and Grow at Your Own Pace",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                        child: Text("Start Your Subscription"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: Text("Browse Catalog"),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search for courses...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Popular Courses
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Popular Courses",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  CourseCard(
                    title: "Introduction to Programming",
                    description: "Learn the fundamentals of programming.",
                    price: "\$29.99",
                  ),
                  CourseCard(
                    title: "Web Development for Beginners",
                    description: "Start building websites from scratch.",
                    price: "\$39.99",
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text("See All Courses"),
                    ),
                  ),
                ],
              ),
            ),

            // Testimonials Section
            Padding(
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
            ),
          ],
        ),
      ),
    );
  }
}

// CourseCard widget
class CourseCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;

  CourseCard({required this.title, required this.description, required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(description, style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 5),
            Text(price, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// TestimonialCard widget
class TestimonialCard extends StatelessWidget {
  final String text;
  final String author;

  TestimonialCard({required this.text, required this.author});

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
