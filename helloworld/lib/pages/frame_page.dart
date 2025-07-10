import 'package:flutter/material.dart';
import 'package:snapbasket/pages/budget_page.dart';
import 'package:snapbasket/pages/login_page.dart';
import 'package:snapbasket/pages/account_page.dart';
import 'package:snapbasket/components/bottom_nav_bar.dart';
import 'package:snapbasket/pages/list_page.dart';
import 'package:snapbasket/pages/home_page.dart';
import 'package:snapbasket/pages/info_page.dart';
import 'package:snapbasket/pages/scanner_page.dart';
import 'package:snapbasket/pages/settings_page.dart';
import 'package:snapbasket/pages/receipts_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FramePage extends StatefulWidget {
  const FramePage({super.key});

  @override
  State<FramePage> createState() => _FramePageState();
}

class _FramePageState extends State<FramePage> {
  int _selectedIndex = 0;

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const ListPage(),
    const ScannerPage(),
    const BudgetPage(),
    const ReceiptsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Icon(Icons.menu, color: Colors.black),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        flexibleSpace: const Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Center(
            child: Text(
              "SnapBasket",
              style: TextStyle(
                fontSize: 40,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF000000), Color(0xFF434343)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  DrawerHeader(child: Image.asset('lib/assets/logo.png')),
                  const Text(
                    "SnapBasket",
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: const Text(
                        'Account',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: ListTile(
                      leading: const Icon(Icons.settings, color: Colors.white),
                      title: const Text(
                        'Impostazioni',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: ListTile(
                      leading: const Icon(Icons.info, color: Colors.white),
                      title: const Text(
                        'Informazioni',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InfoPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, bottom: 25),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Conferma Logout'),
                              content: const Text(
                                'Sei sicuro di voler effettuare il logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Indietro'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await FirebaseAuth.instance.signOut();
                                      if (mounted) {
                                        Navigator.pop(context);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => const LoginPage(),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Errore durante il logout',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Logout'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
