import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:snapbasket/firebase_options.dart';
import 'package:snapbasket/models/home.dart';
import 'package:snapbasket/pages/main_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    FirebaseAuth.instance.setLanguageCode('it');
  } catch (e) {
    print('Errore durante l\'impostazione della lingua: $e');
    FirebaseAuth.instance.setLanguageCode('en');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => Cart())],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainPage(),
      ),
    );
  }
}
