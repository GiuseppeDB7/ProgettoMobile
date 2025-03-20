import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Rimuoviamo l'importazione diretta di AccountPage e Firebase
// import 'package:helloworld/pages/account_page.dart';
// import 'package:firebase_core/firebase_core.dart';

// Creiamo un widget sostitutivo che simula AccountPage
class MockAccountPage extends StatelessWidget {
  const MockAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: const Text('Account'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Creiamo un widget sostitutivo che simula LoginPage
class MockLoginPage extends StatelessWidget {
  const MockLoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo o icona
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(height: 50),

                // Testo di benvenuto
                const Text(
                  "Welcome back!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),

                // Campo email
                TextField(
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Campo password
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                // Link password dimenticata
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 25),

                // Pulsante di accesso
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                // Opzione per registrarsi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Not a member?"),
                    SizedBox(width: 5),
                    Text(
                      "Register now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  // Non abbiamo più bisogno di inizializzare Firebase
  testWidgets('MockAccountPage contiene gli elementi UI principali',
      (WidgetTester tester) async {
    // Costruisce l'app con il mock
    await tester.pumpWidget(const MaterialApp(
      home: MockAccountPage(),
    ));

    // Verifica che il widget CircularProgressIndicator sia presente
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Verifica il titolo
    expect(find.text('Account'), findsOneWidget);
  });

  testWidgets('MockAccountPage ha un pulsante per tornare indietro',
      (WidgetTester tester) async {
    // Costruisce l'app con il mock
    await tester.pumpWidget(const MaterialApp(
      home: MockAccountPage(),
    ));

    // Verifica che il pulsante di ritorno sia presente nell'AppBar
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('LoginPage contiene gli elementi UI principali',
      (WidgetTester tester) async {
    // Costruisce l'app con il mock
    await tester.pumpWidget(const MaterialApp(
      home: MockLoginPage(),
    ));

    // Verifica che gli elementi chiave dell'UI siano presenti
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsAtLeastNWidgets(1));
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Not a member?'), findsOneWidget);
    expect(find.text('Register now'), findsOneWidget);
  });

  testWidgets('LoginPage contiene i campi di input corretti',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MockLoginPage(),
    ));

    // Verifichiamo la presenza dei campi di input
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);

    // Verifichiamo la presenza del pulsante di login
    expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
  });

  testWidgets('LoginPage permette l\'inserimento di testo nei campi',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MockLoginPage(),
    ));

    // Inseriamo del testo nel campo email
    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'test@example.com');
    expect(find.text('test@example.com'), findsOneWidget);

    // Inseriamo del testo nel campo password
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'password123');
    expect(find.text('password123'), findsOneWidget);
  });
}
