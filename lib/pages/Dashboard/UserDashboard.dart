import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:svpa_frontend/map/find_location.dart';
// import 'ParkingSlotSelection_1.dart';
import '../ParkingSlotSelection_1.dart';

class UserDashboardPage extends StatefulWidget {
  final String userId;

  UserDashboardPage({required this.userId});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<UserDashboardPage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the page loads
  }

  Future<void> _fetchUserData() async {
    try {
      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>?;
        });
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

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
        child: userData == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome, ${userData!['fullName']}!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'User ID: ${widget.userId}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),

              // Display User Details
              Text(
                'Email: ${userData!['email']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Mobile: ${userData!['mobile']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Role: ${userData!['role']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Vehicle City: ${userData!['vehicleCity']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Vehicle Class: ${userData!['vehicleClass']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Vehicle No: ${userData!['vehicleNo']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Vehicle Type: ${userData!['vehicleType']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),

              // Display License Image
              userData!['licenseImage'] != null
                  ? Image.network(
                userData!['licenseImage'],
                height: 150,
              )
                  : Text("No license image available"),
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
                icon: Icon(Icons.local_parking, size: 24),
                label: Text('Select Parking Slot'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                  EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                icon: Icon(Icons.map, size: 24),
                label: Text('Find Parking Slot on Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                  EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 40),

              // Logout button or any other actions
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout functionality here')),
                    );
                  },
                  child: Text(
                    'Logout',
                    style:
                    TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
