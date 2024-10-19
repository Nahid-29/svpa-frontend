import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SlotOwnerDashboard extends StatefulWidget {
  @override
  _SlotOwnerDashboardState createState() => _SlotOwnerDashboardState();
}

class _SlotOwnerDashboardState extends State<SlotOwnerDashboard> {
  User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? slotOwnerDetails;

  @override
  void initState() {
    super.initState();
    _fetchSlotOwnerDetails();
  }

  Future<void> _fetchSlotOwnerDetails() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('slotowners')
        .doc(user!.uid)
        .get();

    setState(() {
      slotOwnerDetails = userDoc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Slot Owner Dashboard')),
      body: slotOwnerDetails == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${slotOwnerDetails!['name']}"),
            Text("Email: ${slotOwnerDetails!['email']}"),
            Text("Phone: ${slotOwnerDetails!['phone']}"),
            Text("Role: Slot Owner"),
          ],
        ),
      ),
    );
  }
}
