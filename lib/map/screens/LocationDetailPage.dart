import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationDetailPage extends StatefulWidget {
  final String locationId; // Pass the location ID here

  LocationDetailPage({required this.locationId});

  @override
  _LocationDetailPageState createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? locationDetails;
  List<Map<String, dynamic>> parkingSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchLocationDetails();
  }

  Future<void> _fetchLocationDetails() async {
    // Assuming the locationId is in the format 'Regions/{regionName}/Locations/{locationName}'
    DocumentSnapshot locationSnapshot = await _firestore
        .doc('Regions/${widget.locationId.split('/')[0]}/Locations/${widget.locationId.split('/')[1]}')
        .get();

    if (locationSnapshot.exists) {
      setState(() {
        locationDetails = locationSnapshot.data() as Map<String, dynamic>;
      });
      _fetchParkingSlots();
    }
  }

  Future<void> _fetchParkingSlots() async {
    QuerySnapshot slotsSnapshot = await _firestore
        .collection('Regions/${widget.locationId.split('/')[0]}/Locations/${widget.locationId.split('/')[1]}/parkingSlots')
        .get();

    setState(() {
      parkingSlots = slotsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  Future<void> _addNewSlot(String price, String type) async {
    // Generate a unique ID for the parking slot
    String slotId = DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore.collection('Regions/${widget.locationId.split('/')[0]}/Locations/${widget.locationId.split('/')[1]}/parkingSlots').doc(slotId).set({
      'id': slotId,
      'isOccupied': false,
      'startTime': null,
      'endTime': null,
      'price': double.tryParse(price),
      'type': type,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Parking Slot added successfully!')));
    _fetchParkingSlots(); // Refresh the list of parking slots
  }

  Future<void> _showAddSlotDialog() async {
    String price = '';
    String type = 'Car';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Slot'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Slot Price'),
                onChanged: (value) {
                  price = value;
                },
                keyboardType: TextInputType.number,
              ),
              DropdownButton<String>(
                value: type,
                items: <String>['Car', 'Motorcycle'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    type = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addNewSlot(price, type);
              },
              child: Text('Add Slot'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(locationDetails?['locationName'] ?? 'Location Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: locationDetails == null
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location Name: ${locationDetails!['locationName']}', style: TextStyle(fontSize: 20)),
            Text('Latitude: ${locationDetails!['latitude']}', style: TextStyle(fontSize: 16)),
            Text('Longitude: ${locationDetails!['longitude']}', style: TextStyle(fontSize: 16)),
            Text('Is Verified: ${locationDetails!['isVerified']}', style: TextStyle(fontSize: 16)),
            Text('Ownership Document: ${locationDetails!['ownershipDocument']}', style: TextStyle(fontSize: 16)),
            Text('User ID: ${locationDetails!['userId']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('Parking Slots:', style: TextStyle(fontSize: 20)),
            Expanded(
              child: ListView.builder(
                itemCount: parkingSlots.length,
                itemBuilder: (context, index) {
                  final slot = parkingSlots[index];
                  return ListTile(
                    title: Text('Slot ID: ${slot['id']} - Price: ${slot['price']} - Type: ${slot['type']}'),
                    subtitle: Text('Occupied: ${slot['isOccupied']}'),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showAddSlotDialog,
              child: Text('Add New Slot'),
            ),
          ],
        ),
      ),
    );
  }
}
