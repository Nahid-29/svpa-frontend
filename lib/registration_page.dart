import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController(); // Add email controller
  final _vehicleNoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isCar = true;
  File? _licensePlateImage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _licensePlateImage = File(pickedFile.path);
      }
    });
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final ref = _storage.ref().child('license_plates/${_vehicleNoController.text}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _register() async {
    if (_passwordController.text == _confirmPasswordController.text) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String? imageUrl;
        if (_licensePlateImage != null) {
          imageUrl = await _uploadImage(_licensePlateImage!);
        }

        // Save user data in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _nameController.text.trim(),
          'mobile': _mobileController.text.trim(),
          'email': _emailController.text.trim(),
          'vehicleNumber': _vehicleNoController.text.trim(),
          'isCar': isCar,
          'licensePlateImage': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );

        Navigator.pushNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create account: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text('Register User', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
              SizedBox(height: 10),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder())), // Email field
              SizedBox(height: 10),
              TextField(controller: _mobileController, decoration: InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),
              SizedBox(height: 10),
              TextField(controller: _vehicleNoController, decoration: InputDecoration(labelText: 'Vehicle Number', border: OutlineInputBorder())),
              SizedBox(height: 10),
              TextButton(onPressed: _pickImage, child: Text(_licensePlateImage == null ? 'Upload License Plate Picture' : 'License Plate Picture Selected')),
              SizedBox(height: 10),
              TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
              SizedBox(height: 10),
              TextField(controller: _confirmPasswordController, obscureText: true, decoration: InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder())),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: Text('Create Account')),
              TextButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: Text('Already a member? Sign In')),
            ],
          ),
        ),
      ),
    );
  }
}
