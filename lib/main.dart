import 'package:flutter/material.dart';
import 'package:svpa_frontend/pages/Dashboard/SlotOwnerDashboard.dart';
import 'package:svpa_frontend/pages/Dashboard/UserDashboard.dart';
import 'package:svpa_frontend/pages/LoginPage.dart';
import 'package:svpa_frontend/pages/SlotOwnerRegistrationPage.dart';
import 'package:svpa_frontend/pages/user_registration_page.dart';
import 'pages/LoginPage.dart';
import 'registration_page.dart';
import 'dashboard_page.dart';
import 'pages/map_page.dart';


import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(SmartVehicleParkingApp());
  // runApp(MyApp());
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
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register-user': (context) => UserRegistrationPage(),
        '/register-slot-owner': (context) => SlotOwnerRegistrationPage(),
        '/dashboard': (context) => DashboardPage(),
        '/user-dashboard': (context) => UserDashboard(),
        '/slot-owner-dashboard': (context) => SlotOwnerDashboard(),
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
