import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatelessWidget {
  final void Function(int)? onTabChange;
  const MyBottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 51, 51, 51), // Colore scuro solido
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
        child: GNav(
          color: Colors.white60,
          activeColor: Colors.white,
          tabBackgroundColor: Colors.white.withOpacity(0.1),
          gap: 8,
          tabBorderRadius: 15,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          duration: const Duration(milliseconds: 300),
          tabs: const [
            GButton(
              icon: Icons.home_rounded,
              text: 'Home',
              textStyle: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            GButton(
              icon: Icons.format_list_bulleted_rounded,
              text: 'Lists',
              textStyle: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            GButton(
              icon: Icons.document_scanner_rounded,
              text: 'Scanner',
              textStyle: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            GButton(
              icon: Icons.payments_rounded, // Pagamenti/Finanze
              text: 'Budget',
              textStyle: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            GButton(
              icon: Icons.receipt_rounded,
              text: 'Receipts',
              textStyle: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          selectedIndex: 0,
          onTabChange: onTabChange,
        ),
      ),
    );
  }
}
