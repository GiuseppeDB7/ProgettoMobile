import 'package:flutter/material.dart';
import 'package:snapbasket/pages/frame_page.dart';
import 'package:snapbasket/pages/account_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FramePage()),
            );
          },
        ),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            // Sezione Account
            const Text(
              "Account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notifications"),
              trailing: Switch(
                value: true, // Valore da gestire con stato
                onChanged: (bool value) {
                  // Gestire il cambio di stato
                },
              ),
            ),

            const SizedBox(height: 25),
            // Sezione App
            const Text(
              "App",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Language"),
              trailing: const Text("Italian"),
              onTap: () {
                // Azione per la lingua
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("Dark Theme"),
              trailing: Switch(
                value: false, // Valore da gestire con stato
                onChanged: (bool value) {
                  // Gestire il cambio di stato
                },
              ),
            ),

            const SizedBox(height: 25),
            // Sezione Informazioni
            const Text(
              "Info",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text("App Version"),
              trailing: Text("1.0.0"),
            ),
            ListTile(
              leading: const Icon(Icons.policy),
              title: const Text("Privacy Policy"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Azione per privacy policy
              },
            ),
          ],
        ),
      ),
    );
  }
}
