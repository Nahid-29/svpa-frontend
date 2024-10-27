import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import '../LoginPage.dart'; // Import your LoginPage
import '../../map/screens/AddNewLocation.dart';

class SlotOwnerDashboard extends StatelessWidget {
  final String uid;

  SlotOwnerDashboard({required this.uid});

  // Logout function
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged out successfully!')),
      );
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Welcome Slot Owner! Your UID is: $uid',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),

            // Button to Find Parking Slot on Map
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNewLocationPage(userId: uid),
                  ),
                );
              },
              icon: Icon(Icons.map, size: 24),
              label: Text('Find Parking Slot on Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 20),

            // Display the list of locations
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Regions').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final regions = snapshot.data!.docs;

                  if (regions.isEmpty) {
                    return Center(child: Text('No regions found.'));
                  }

                  return FutureBuilder<List<DocumentSnapshot>>(
                    future: _fetchLocationsForUser(regions),
                    builder: (context, futureSnapshot) {
                      if (futureSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (futureSnapshot.hasError) {
                        return Center(child: Text('Error: ${futureSnapshot.error}'));
                      }

                      final userLocations = futureSnapshot.data;

                      if (userLocations!.isEmpty) {
                        return Center(child: Text('No locations found for your UID.'));
                      }

                      return ListView.builder(
                        itemCount: userLocations.length,
                        itemBuilder: (context, index) {
                          var locationData = userLocations[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(locationData['locationName']),
                              subtitle: Text(
                                'Latitude: ${locationData['latitude']}, Longitude: ${locationData['longitude']}',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context), // Button for logout
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchLocationsForUser(List<QueryDocumentSnapshot> regions) async {
    List<DocumentSnapshot> userLocations = [];

    for (var region in regions) {
      var locationsSnapshot = await FirebaseFirestore.instance
          .collection('Regions')
          .doc(region.id)
          .collection('Locations')
          .where('userId', isEqualTo: uid)
          .get();

      userLocations.addAll(locationsSnapshot.docs);
    }

    return userLocations;
  }
}
