import 'package:flutter/material.dart';
import 'pages/catalog_page.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  _HeroSectionState createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch() {
    String searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CatalogPage(searchQuery: searchTerm),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bgcat.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 90),
          const Text(
            "The Best Foreign Language & Technology Tutorials",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 100),
          const Text(
            "And the easy way to learn The World",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),

          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("Start Your Subscription"),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CatalogPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("Browse Catalog"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 70),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What are you going to learn next?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search for courses...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _performSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Icon(Icons.search),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
