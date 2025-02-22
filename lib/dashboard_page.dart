import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:course/dashboard/activity_dashboard.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Create an instance of FlutterSecureStorage to manage the token.
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Logout function: delete the token and navigate to login.
  Future<void> _logout() async {
    await secureStorage.delete(key: 'token');
    Navigator.pushReplacementNamed(context, '/main');
  }

  /// Builds a custom Tab widget that shows larger icons only in portrait
  /// and both icons and text in landscape mode.
  Widget _buildTab(
      String label, IconData iconSelected, IconData iconUnselected, int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        bool isSelected = _tabController.index == index;
        bool isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? iconSelected : iconUnselected,
              size: isLandscape ? 20 : 28,
            ),
            if (isLandscape) const SizedBox(width: 4),
            if (isLandscape)
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? const Color(0xFF6200EE)
                      : Colors.black.withOpacity(0.60),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Builds an elegant Drawer (sidebar) with navigation items and a logout button.
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF93C5FD), // Light blue
              Color(0xFFE0BBE4), // Light purple
              Color(0xFFFECACA), // Light pink
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Center(
                child: Text(
                  "Navigation",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
                // Optionally, add navigation logic if needed.
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings page.
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Dashboard"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF93C5FD),
                Color(0xFFE0BBE4),
                Color(0xFFFECACA),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6200EE),
          indicatorWeight: 2,
          tabs: [
            _buildTab("Activity", Icons.show_chart, Icons.insert_chart_outlined, 0),
            _buildTab("Account", Icons.person, Icons.person_outline, 1),
            _buildTab("Bookmarks", Icons.bookmark, Icons.bookmark_border, 2),
            _buildTab("Completed", Icons.check_circle, Icons.check_circle_outline, 3),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ActivityDashboard(),
          AccountWidget(),
          BookmarksWidget(),
          CompletedWidget(),
        ],
      ),
    );
  }
}



/// Placeholder for the Account tab content.
class AccountWidget extends StatelessWidget {
  const AccountWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Account Content"));
  }
}

/// Placeholder for the Bookmarks tab content.
class BookmarksWidget extends StatelessWidget {
  const BookmarksWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Bookmarks Content"));
  }
}

/// Placeholder for the Completed tab content.
class CompletedWidget extends StatelessWidget {
  const CompletedWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Completed Content"));
  }
}
