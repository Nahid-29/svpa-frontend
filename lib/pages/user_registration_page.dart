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

        // Navigate to login page after successful registration
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Registration'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                // Mobile Number
                TextFormField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 10) {
                      return 'Please enter a valid mobile number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                // Vehicle Type Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Vehicle Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Car', 'Motorcycle'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _vehicleType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a vehicle type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                // Vehicle Details
                TextFormField(
                  controller: _vehicleCityController,
                  decoration: InputDecoration(
                    labelText: 'Vehicle City',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your vehicle\'s city';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                TextFormField(
                  controller: _vehicleClassController,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Class',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your vehicle\'s class';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                TextFormField(
                  controller: _vehicleNoController,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Number',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your vehicle number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                // License Image Picker
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    backgroundColor: Colors.blueAccent,
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  child: Text('Upload License Plate Image'),
                ),
                _licenseImage != null ? Image.file(_licenseImage!) : Container(),
                SizedBox(height: 16.0),

                // Password Fields
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),

                // Register Button
                ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    backgroundColor: Colors.blueAccent,
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  child: Text('Register'),
                ),
                SizedBox(height: 16.0),

                // Login Navigation
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: Text(
                      'Already have an account? Login here',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
