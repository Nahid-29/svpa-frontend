import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SlotOwnerRegistrationPage extends StatefulWidget {
  @override
  _SlotOwnerRegistrationPageState createState() => _SlotOwnerRegistrationPageState();
}

class _SlotOwnerRegistrationPageState extends State<SlotOwnerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  File? _nidFrontImage;
  File? _nidBackImage;

  Future<void> _pickNidImage(bool isFront) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isFront) {
          _nidFrontImage = File(image.path);
        } else {
          _nidBackImage = File(image.path);
        }
      });
    }
  }

  Future<void> _registerSlotOwner() async {
    if (_formKey.currentState!.validate()) {
      try {
        QuerySnapshot nidCheck = await FirebaseFirestore.instance
            .collection('slotOwners')
            .where('nid', isEqualTo: _nidController.text)
            .get();

        if (nidCheck.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("NID already registered!")),
          );
          return;
        }

        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        String? nidFrontUrl;
        String? nidBackUrl;
        if (_nidFrontImage != null && _nidBackImage != null) {
          final storageRef = FirebaseStorage.instance.ref();
          final frontRef = storageRef.child("nidCards/${userCredential.user!.uid}_front.jpg");
          final backRef = storageRef.child("nidCards/${userCredential.user!.uid}_back.jpg");

          await frontRef.putFile(_nidFrontImage!);
          await backRef.putFile(_nidBackImage!);

          nidFrontUrl = await frontRef.getDownloadURL();
          nidBackUrl = await backRef.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('slotOwners').doc(userCredential.user!.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'nid': _nidController.text,
          'nidFrontImage': nidFrontUrl,
          'nidBackImage': nidBackUrl,
          'address': _addressController.text,
          'role': 'slotowner',
          'isVerified': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Slot owner registered successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slot Owner Registration', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_phoneController, 'Phone'),
              _buildTextField(_nidController, 'NID Number'),
              _buildTextField(_addressController, 'Full Address'),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Upload NID Images", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _pickNidImage(true),
                        child: Text('NID Front'),
                      ),
                      SizedBox(height: 8),
                      _nidFrontImage != null
                          ? Image.file(_nidFrontImage!, width: 100, height: 100, fit: BoxFit.cover)
                          : Container(width: 100, height: 100, color: Colors.grey[300]),
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _pickNidImage(false),
                        child: Text('NID Back'),
                      ),
                      SizedBox(height: 8),
                      _nidBackImage != null
                          ? Image.file(_nidBackImage!, width: 100, height: 100, fit: BoxFit.cover)
                          : Container(width: 100, height: 100, color: Colors.grey[300]),
                    ],
                  ),
                ],
              ),

              _buildTextField(_passwordController, 'Password', obscureText: true),
              _buildTextField(_confirmPasswordController, 'Confirm Password', obscureText: true),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _registerSlotOwner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
