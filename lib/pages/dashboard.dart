import 'package:flutter/material.dart';
import 'package:svpa_frontend/map/find_location.dart';
// import 'ParkingSlotSelectionPage.dart';
import 'ParkingSlotSelection_1.dart';// Import the ParkingSlotSelectPage

class DashboardPage extends StatelessWidget {
  final String userId;  // Receive the userId from the login page

  DashboardPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Welcome Text
            Text(
              'Welcome to the Dashboard!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Your User ID: $userId',  // Display the userId
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 40),

            // Button to Navigate to ParkingSlotSelectPage
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParkingSlotSelectPage_1(),
                  ),
                );
              },
              icon: Icon(Icons.local_parking, size: 24), // Add parking icon
              label: Text('Select Parking Slot'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Background color
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Button to Find Parking Slot on Map
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FindLocation(),
                  ),
                );
              },
              icon: Icon(Icons.map, size: 24), // Add map icon
              label: Text('Find Parking Slot on Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Background color
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 40),

            // Add logout button or any other optional actions if required
            Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: () {
                  // Implement logout or other actions here
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout functionality here')));
                },
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
