import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../LoginPage.dart'; // Make sure to import your LoginPage

// SlotOwnerDashboard.dart
class SlotOwnerDashboard extends StatelessWidget {
  final String uid;

  SlotOwnerDashboard({required this.uid});

  // Logout function
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Optionally show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged out successfully!')),
      );
      // Navigate to LoginPage
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slot Owner Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context), // Call logout function
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome Slot Owner! Your UID is: $uid'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context), // Button for logout
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Optional: set a different color for the button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
