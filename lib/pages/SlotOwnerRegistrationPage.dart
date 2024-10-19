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

  // Controllers to retain input data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  File? _nidFrontImage;
  File? _nidBackImage;

  // Pick NID images
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
        // Check for duplicate NID
        QuerySnapshot nidCheck = await FirebaseFirestore.instance
            .collection('slotOwners')
            .where('nid', isEqualTo: _nidController.text)
            .get();

        if (nidCheck.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("NID already registered!")));
          return;
        }

        // Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Upload NID card images to Firebase Storage
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

        // Firestore: Save slot owner data
        await FirebaseFirestore.instance.collection('slotOwners').doc(userCredential.user!.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'nid': _nidController.text,
          'nidFrontImage': nidFrontUrl,
          'nidBackImage': nidBackUrl,
          'address': _addressController.text,
          'role': 'slotowner',
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Slot owner registered successfully!")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Slot Owner Registration')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // Name, Email, Phone, NID No
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextFormField(
              controller: _nidController,
              decoration: InputDecoration(labelText: 'NID Number'),
            ),
            // Address
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Full Address'),
            ),
            // Upload NID Front and Back Image
            ElevatedButton(
              onPressed: () => _pickNidImage(true),
              child: Text('Upload NID Front Image'),
            ),
            _nidFrontImage != null ? Image.file(_nidFrontImage!) : Container(),
            ElevatedButton(
              onPressed: () => _pickNidImage(false),
              child: Text('Upload NID Back Image'),
            ),
            _nidBackImage != null ? Image.file(_nidBackImage!) : Container(),
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
              onPressed: _registerSlotOwner,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
