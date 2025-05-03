import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  
  bool isLogin = true; // Toggle between Login & Signup

  String emailError = '';
  String passwordError = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    final emailRegex = RegExp(r'^[\w-\.]+@(gmail|outlook|yahoo|hotmail)\.(com|net|org)$');
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');

    setState(() {
      emailError = '';
      passwordError = '';
    });

    bool hasError = false;

    if (email.isEmpty) {
      setState(() => emailError = 'Email is required');
      hasError = true;
    } else if (!emailRegex.hasMatch(email)) {
      setState(() => emailError = 'Please use a valid Gmail, Outlook, or Yahoo email');
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => passwordError = 'Password is required');
      hasError = true;
    } else if (!passwordRegex.hasMatch(password)) {
      setState(() => passwordError = 'Password must contain at least one uppercase letter, one number, and be at least 8 characters');
      hasError = true;
    }

    if (hasError) return;

    try {
      UserCredential userCredential;
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        await userCredential.user?.sendEmailVerification();
        userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      }

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      String message = "Something went wrong.";
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          message = "No user found for that email. Please register";
        } else if (e.code == 'wrong-password') {
          message = "Wrong password.";
        } else if (e.code == 'email-already-in-use') {
          message = "Email is already registered.";
        } else {
          message = e.message ?? message;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Widget buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    bool isPassword = false,
    String? errorText,
  }) {
    bool isFocused = focusNode.hasFocus;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? Color(0xFF39FF14).withOpacity(0.8)
                : Color(0xFF39FF14).withOpacity(0.4),
            blurRadius: isFocused ? 12 : 6,
            spreadRadius: isFocused ? 3 : 1,
          ),
        ],
        border: Border.all(color: Color(0xFF39FF14)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          errorText: errorText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
        onTap: () {
          setState(() {}); // Refresh UI when field is focused
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(isLogin ? "Login" : "Sign Up"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildInputField(
              controller: emailController,
              focusNode: emailFocusNode,
              label: "Email",
              errorText: emailError.isNotEmpty ? emailError : null,
            ),
            buildInputField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              label: "Password",
              isPassword: true,
              errorText: passwordError.isNotEmpty ? passwordError : null,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                side: BorderSide(color: Color(0xFF39FF14)),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isLogin ? "Login" : "Sign Up",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF39FF14),
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(
                isLogin ? "Create an account" : "Already have an account? Login",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF39FF14),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
