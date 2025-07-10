import 'package:flutter/material.dart';
import 'package:snapbasket/pages/frame_page.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

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
          "Informazioni",
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            const Text(
              "Sviluppatori",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text("Di Biase Giuseppe"),
              subtitle: Text("Sviluppatore Backend"),
            ),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text("De Luca Davide"),
              subtitle: Text("Designer Frontend"),
            ),
            const Divider(),

            const SizedBox(height: 15),
            const Text(
              "Contatti",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email"),
              subtitle: const Text("support@snapbasket.com"),
              onTap: () {
                // Azione per inviare email
              },
            ),
            ListTile(
              leading: const Icon(Icons.web),
              title: const Text("Sito Web"),
              subtitle: const Text("www.snapbasket.com"),
              onTap: () {
                // Azione per aprire il sito web
              },
            ),

            const Spacer(),

            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Image.asset(
                  'lib/assets/logo.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
