import 'package:flutter/material.dart';
import 'package:course/services/auth_service.dart';


class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final ApiService _apiService = ApiService();  // Use existing API service
  String email = '';
  String code = '';
  int step = 1;
  String message = '';
  bool loading = false;
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final response = await _apiService.get('user'); // Fetch user data
      if (response.data['data']?['email'] != null) {
        setState(() {
          email = response.data['data']['email'];
          isAuthenticated = true;
        });
      }
    } catch (error) {
      print("Failed to fetch user: $error");
    }
  }


  Future<void> sendVerificationCode() async {
    setState(() {
      loading = true;
      message = '';
    });

    try {
      final response = await _apiService.post('send-verification-code', {'email': email});
      setState(() {
        message = response.data['message'];
        step = 2;
      });
    } catch (error) {
      setState(() {
        message = 'Error sending code';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> verifyCode() async {
    setState(() {
      loading = true;
      message = '';
    });

    try {
      final response = await _apiService.post('send-verification-code', {'email': email});
      setState(() {
        message = response.data['message'];
        step = 3;
      });
    } catch (error) {
      setState(() {
        message = 'Error verifying code';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Email Verification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (step == 1) ...[
              if (isAuthenticated)
                Text("Verification will be sent to: $email", textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : sendVerificationCode,
                child: Text(loading ? 'Sending...' : 'Send Code'),
              ),
            ] else if (step == 2) ...[
              const Text("Enter the 3-digit code sent to your email."),
              TextField(
                onChanged: (value) => code = value,
                decoration: const InputDecoration(labelText: "Enter code"),
                keyboardType: TextInputType.number,
                maxLength: 3,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: loading ? null : verifyCode,
                child: Text(loading ? 'Verifying...' : 'Verify Code'),
              ),
            ] else if (step == 3) ...[
              const Text(
                "Your email has been verified successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green),
              ),
            ],
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.blue)),
              ),
          ],
        ),
      ),
    );
  }
}
