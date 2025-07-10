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
          "Impostazioni",
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            const Text(
              "Account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profilo"),
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
              title: const Text("Notifiche"),
              trailing: Switch(
                value: true,
                onChanged: (bool value) {
                  // Gestire il cambio di stato
                },
              ),
            ),

            const SizedBox(height: 25),
            const Text(
              "App",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Lingua"),
              trailing: const Text("Italiano"),
              onTap: () {
                // Azione per la lingua
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("Tema Scuro"),
              trailing: Switch(
                value: false,
                onChanged: (bool value) {
                  // Gestire il cambio di stato
                },
              ),
            ),

            const SizedBox(height: 25),
            const Text(
              "Info",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text("Versione App"),
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
