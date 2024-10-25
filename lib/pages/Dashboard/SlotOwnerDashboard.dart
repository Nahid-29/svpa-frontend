import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// SlotOwnerDashboard.dart
class SlotOwnerDashboard extends StatelessWidget {
  final String uid;

  SlotOwnerDashboard({required this.uid});

  @override
  Widget build(BuildContext context) {
    // You can now use the uid for fetching slot owner-specific data
    return Scaffold(
      appBar: AppBar(
        title: Text('Slot Owner Dashboard'),
      ),
      body: Center(
        child: Text('Welcome Slot Owner! Your UID is: $uid'),
      ),
    );
  }
}