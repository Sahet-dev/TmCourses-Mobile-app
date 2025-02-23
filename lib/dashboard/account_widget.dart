// account_widget.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:course/services/auth_service.dart';

/// A simple User model to parse the API response.
class User {
  final int id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }
}

class AccountWidget extends StatefulWidget {
  const AccountWidget({super.key});

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  late Future<User> _userFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
  }

  Future<User> _fetchUser() async {
    try {
      final response = await _apiService.get('user');
      final Map<String, dynamic> jsonResponse = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (jsonResponse.containsKey('data')) {
        return User.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Unexpected JSON structure: $jsonResponse');
      }
    } catch (error) {
      throw Exception('Failed to load user data: $error');
    }
  }

  Widget _buildUserCard(User user) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              leading: const Icon(Icons.perm_identity),
              title: Text('ID: ${user.id}',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(user.email,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: Text('Role: ${user.role}',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.red),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          return _buildUserCard(snapshot.data!);
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: _buildContent());
  }
}
