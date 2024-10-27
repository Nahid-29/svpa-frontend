import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddNewLocationPage extends StatefulWidget {
  final String userId; // User UID passed from the previous page

  AddNewLocationPage({required this.userId});

  @override
  _AddNewLocationPageState createState() => _AddNewLocationPageState();
}

class _AddNewLocationPageState extends State<AddNewLocationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? selectedRegion;
  String? ownershipDocumentUrl;
  List<String> regions = [];
  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchRegions();
  }

  Future<void> _fetchRegions() async {
    final QuerySnapshot snapshot = await _firestore.collection('Regions').get();
    setState(() {
      regions = snapshot.docs.map((doc) => doc['regionName'] as String).toList(); // Assuming region has a 'name' field
    });
  }

  Future<void> _uploadOwnershipDocument() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery); // Use ImageSource.file for other file types
    if (file != null) {
      final String fileName = file.name;
      final Reference ref = _storage.ref().child('ownership_documents/$fileName');

      await ref.putFile(File(file.path)); // Use File(file.path) for files
      ownershipDocumentUrl = await ref.getDownloadURL();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Document uploaded successfully!')));
    }
  }

  Future<void> _addNewLocation() async {
    if (selectedRegion != null && locationNameController.text.isNotEmpty && ownershipDocumentUrl != null &&
        latitudeController.text.isNotEmpty && longitudeController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected Region $selectedRegion')));
      await _firestore.collection('Regions').doc(selectedRegion).collection('Locations').doc(locationNameController.text).set({
        'locationName': locationNameController.text,
        'latitude': double.tryParse(latitudeController.text),
        'longitude': double.tryParse(longitudeController.text),
        'userId': widget.userId,
        'isVerified': false,
        'ownershipDocument': ownershipDocumentUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location added successfully!')));
      Navigator.pop(context); // Go back to the previous page after adding
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Location')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Select Region'),
              value: selectedRegion,
              onChanged: (String? newValue) {
                setState(() {
                  selectedRegion = newValue;
                });
              },
              items: regions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: locationNameController,
              decoration: InputDecoration(labelText: 'Location Name'),
            ),
            TextField(
              controller: latitudeController,
              decoration: InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: longitudeController,
              decoration: InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadOwnershipDocument,
              child: Text('Upload Ownership Document'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addNewLocation,
              child: Text('Add Location'),
            ),
          ],
        ),
      ),
    );
  }
}
