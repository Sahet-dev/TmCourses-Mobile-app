import 'package:flutter/material.dart';
import 'package:course/services/auth_service.dart';

class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final ApiService _authService = ApiService();
  final TextEditingController _codeController = TextEditingController();
  bool isLoading = false;
  String message = "";
  int step = 1; // 1 = Request Code, 2 = Enter Code

  void sendCode() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      await _authService.sendVerificationCode();
      setState(() {
        step = 2;
        message = "A verification code has been sent to your email.";
      });
    } catch (e) {
      setState(() {
        message = "Failed to send verification code.";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void verifyCode() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    bool success = await _authService.verifyCode(_codeController.text);
    if (success) {
      setState(() {
        message = "Email verified successfully!";
        step = 3;
      });
    } else {
      setState(() {
        message = "Invalid or expired code.";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Verification')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (step == 1) ...[
              const Text("Click the button below to send a verification code."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : sendCode,
                child: Text(isLoading ? "Sending..." : "Send Code"),
              ),
            ],
            if (step == 2) ...[
              const Text("Enter the 3-digit code sent to your email."),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 3,
              ),
              ElevatedButton(
                onPressed: isLoading ? null : verifyCode,
                child: Text(isLoading ? "Verifying..." : "Verify Code"),
              ),
            ],
            if (step == 3) ...[
              const Text("Your email has been verified!"),
            ],
            if (message.isNotEmpty)
              Text(message, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
