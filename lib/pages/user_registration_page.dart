import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserRegistrationPage extends StatefulWidget {
  @override
  _UserRegistrationPageState createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to retain the input data
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _vehicleCityController = TextEditingController();
  final TextEditingController _vehicleClassController = TextEditingController();
  final TextEditingController _vehicleNoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _vehicleType;
  File? _licenseImage;

  // Pick license image
  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _licenseImage = File(image.path);
      });
    }
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Check for duplicate vehicle number
        QuerySnapshot vehicleCheck = await FirebaseFirestore.instance
            .collection('users')
            .where('vehicleNo', isEqualTo: _vehicleNoController.text)
            .get();

        if (vehicleCheck.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Vehicle number already registered!")));
          return;
        }

        // Upload license plate image to Firebase Storage
        String? imageUrl;
        if (_licenseImage != null) {
          final storageRef = FirebaseStorage.instance.ref().child("licensePlates/${userCredential.user!.uid}.jpg");
          await storageRef.putFile(_licenseImage!);
          imageUrl = await storageRef.getDownloadURL();
        }

        // Firestore: Save user data
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'mobile': _mobileController.text,
          'vehicleType': _vehicleType,
          'vehicleCity': _vehicleCityController.text,
          'vehicleClass': _vehicleClassController.text,
          'vehicleNo': _vehicleNoController.text,
          'licenseImage': imageUrl,
          'role': 'user',
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("User registered successfully!")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Registration')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // Full Name, Email, Mobile Number
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _mobileController,
              decoration: InputDecoration(labelText: 'Mobile Number'),
            ),
            // Dropdowns for Vehicle Type and City
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Vehicle Type'),
              items: ['Car', 'Motorcycle'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _vehicleType = value;
                });
              },
            ),
            // Other fields for vehicle details
            TextFormField(
              controller: _vehicleCityController,
              decoration: InputDecoration(labelText: 'Vehicle City'),
            ),
            TextFormField(
              controller: _vehicleClassController,
              decoration: InputDecoration(labelText: 'Vehicle Class'),
            ),
            TextFormField(
              controller: _vehicleNoController,
              decoration: InputDecoration(labelText: 'Vehicle Number'),
            ),
            // License Image Picker
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload License Plate Image'),
            ),
            _licenseImage != null ? Image.file(_licenseImage!) : Container(),
            // Password Fields
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            // Submit Button
            ElevatedButton(
              onPressed: _registerUser,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
