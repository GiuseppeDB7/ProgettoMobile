import 'package:flutter/material.dart';
import 'package:snapbasket/pages/frame_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  // Funzione per ottenere i dati dell'utente
  Future<DocumentSnapshot> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
  }

  // Metodo per aggiornare i dati dell'utente
  Future<void> updateUserField(String field, dynamic value) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      field: value,
    });
  }

  // Metodo per mostrare il dialog di modifica
  void showEditDialog(BuildContext context, String field, String currentValue) {
    final TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit $field'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Enter new $field'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    // Gestione speciale per l'età (conversione in int)
                    final value =
                        field == 'age'
                            ? int.parse(controller.text)
                            : controller.text;

                    await updateUserField(field, value);
                    if (context.mounted) {
                      Navigator.pop(context);
                      // Aggiorna la pagina
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountPage(),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

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
          "Account",
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sezione Profilo
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${userData['firstName']} ${userData['lastName']}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sezione Informazioni Personali
                    const Text(
                      "User preferences",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text("Email"),
                      subtitle: Text(userData['email']),
                      // Rimossi trailing e onTap per disabilitare la modifica
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text("Age"),
                      subtitle: Text("${userData['age']} years"),
                      trailing: const Icon(Icons.edit),
                      onTap:
                          () => showEditDialog(
                            context,
                            'age',
                            userData['age'].toString(),
                          ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text("Phone"),
                      subtitle: Text(userData['phone'] ?? "+39 XXX XXX XXXX"),
                      trailing: const Icon(Icons.edit),
                      onTap:
                          () => showEditDialog(
                            context,
                            'phone',
                            userData['phone'] ?? "",
                          ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text("Address"),
                      subtitle: Text(userData['address'] ?? "Via Example, 123"),
                      trailing: const Icon(Icons.edit),
                      onTap:
                          () => showEditDialog(
                            context,
                            'address',
                            userData['address'] ?? "",
                          ),
                    ),

                    const SizedBox(height: 30),

                    // Pulsante Delete Profile
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          backgroundColor: const Color.fromARGB(
                            255,
                            206,
                            19,
                            6,
                          ),
                        ),
                        onPressed: () {
                          // Da implementare
                        },
                        child: const Text(
                          "Delete profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('No user data found'));
        },
      ),
    );
  }
}
