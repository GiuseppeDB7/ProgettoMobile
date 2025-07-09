import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapbasket/pages/frame_page.dart';
import 'package:snapbasket/pages/login_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the user is logged in
          if (snapshot.hasData) {
            return const FramePage();
          }
          // If the user is not logged in
          else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
