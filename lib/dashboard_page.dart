import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? userId;
  Map<String, dynamic>? userData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the user ID passed from the login page
    userId = ModalRoute.of(context)!.settings.arguments as String;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Fetch user data from Firestore using userId
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        userData = snapshot.data() as Map<String, dynamic>?;
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${userData!['name']}', style: TextStyle(fontSize: 20)),
            Text('Email: ${userData!['email']}', style: TextStyle(fontSize: 20)),
            Text('Mobile: ${userData!['mobile']}', style: TextStyle(fontSize: 20)),
            Text('Vehicle Number: ${userData!['vehicleNumber']}', style: TextStyle(fontSize: 20)),
            Text('Vehicle Type: ${userData!['isCar'] ? 'Car' : 'Motorbike'}', style: TextStyle(fontSize: 20)),
            if (userData!['licensePlateImage'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Image.network(userData!['licensePlateImage']),
              ),
          ],
        ),
      ),
    );
  }
}
