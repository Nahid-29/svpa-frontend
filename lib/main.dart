import 'package:flutter/material.dart';
import 'package:svpa_frontend/map/find_location.dart';
import 'package:svpa_frontend/pages/Dashboard/SlotOwnerDashboard.dart';
import 'package:svpa_frontend/pages/Dashboard/UserDashboard.dart';
import 'package:svpa_frontend/pages/LoginPage.dart';
import 'package:svpa_frontend/pages/Registration/SlotOwnerRegistrationPage.dart';
import 'pages/Registration/user_registration_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'map/models/addParkingDataToFirestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(SmartVehicleParkingApp());
  addParkingDataToFirestore();
}

class SmartVehicleParkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Vehicle Parking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register-user': (context) => UserRegistrationPage(),
        '/register-slot-owner': (context) => SlotOwnerRegistrationPage(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          // User is logged in
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users') // Check in 'users' collection first
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                // User exists in 'users', check their role
                String role = userSnapshot.data!['role'];
                if (role == 'slotOwner') {
                  return SlotOwnerDashboard(uid: snapshot.data!.uid);
                } else {
                  return UserDashboardPage(userId: snapshot.data!.uid);
                }
              } else {
                // If user is not found in 'users', check in 'slotOwners'
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('slotOwners')
                      .doc(snapshot.data!.uid)
                      .get(),
                  builder: (context, slotOwnerSnapshot) {
                    if (slotOwnerSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (slotOwnerSnapshot.hasData && slotOwnerSnapshot.data!.exists) {
                      // User exists in 'slotOwners', return the SlotOwnerDashboard
                      return SlotOwnerDashboard(uid: snapshot.data!.uid);
                    } else {
                      // User not found in either collection
                      return LoginPage();
                    }
                  },
                );
              }
            },
          );
        } else {
          // User is not logged in
          return LoginPage();
        }
      },
    );
  }
}
