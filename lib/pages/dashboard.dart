import 'package:flutter/material.dart';
import 'package:svpa_frontend/map/find_location.dart';
import 'ParkingSlotSelectionPage.dart'; // Import the ParkingSlotSelectPage

class DashboardPage extends StatelessWidget {
  final String userId;  // Receive the userId from the login page

  DashboardPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Dashboard!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Your User ID: $userId',  // Display the userId
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),

            // Button to Navigate to ParkingSlotSelectPage
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParkingSlotSelectPage(),
                  ),
                );
              },
              child: Text('Go to Parking Slot Selection'),
            ),
            SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FindLocation(),
                  ),
                );
              },
              child: Text('Go to Parking Slot Selection'),
            ),
          ],
        ),
      ),
    );
  }
}
