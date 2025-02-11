import 'package:flutter/material.dart';
import 'pages/catalog_page.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bgcat.png'), // Change to your image path
          fit: BoxFit.cover, // Makes sure the image covers the whole container
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 90), // Space at the top
          Text(
            "The Best Foreign Language & Technology Tutorials",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 100), // Space below the title
          Text(
            "And the easy way to learn The World",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 20),

          // Column instead of Row to stack buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity, // Full width
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(vertical: 15), // Only vertical padding
                  ),
                  child: Text("Start Your Subscription"),
                ),
              ),
              SizedBox(height: 15), // Space between buttons
              SizedBox(
                width: double.infinity, // Full width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CatalogPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 15), // Only vertical padding
                  ),
                  child: Text("Browse Catalog"),
                ),
              ),
            ],
          ),

          SizedBox(height: 70),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
              children: [
                Text(
                  "What are you going to learn next?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10), // Space between text and input
                TextField(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
