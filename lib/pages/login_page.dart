import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:course/pages/emailverif.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMsg = "";

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMsg = "";
    });

    try {
      Dio dio = Dio();
      Response response = await dio.post(
        "https://course-server.sahet-dev.com/api/login",
        data: {
          "email": emailController.text,
          "password": passwordController.text
        },
      );

      if (response.statusCode == 200) {
        String token = response.data["token"];
        bool emailVerified = response.data["email_verified"] ?? false;

        await secureStorage.write(key: 'token', value: token);
        print("Token saved securely: $token");

        if (!emailVerified) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => EmailVerificationPage()));
        } else {
          Navigator.pushReplacementNamed(context, "/home");
        }
      }
    } catch (e) {
      setState(() {
        errorMsg = "Login failed. Please check your credentials.";
      });
      print("Login Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade500,
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Login", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              if (errorMsg.isNotEmpty) Text(errorMsg, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
