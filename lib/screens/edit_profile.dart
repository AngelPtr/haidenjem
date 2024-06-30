import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haidenjem/main.dart';
import 'package:haidenjem/screens/profile_screen.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
              color: Colors.lightGreenAccent), // change the title color to red
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black // Dark mode
            : Colors.green[900], // Light mode
        elevation: 0,
        leading: IconButton(
          icon: Theme(
            data: Theme.of(context).copyWith(
                iconTheme: const IconThemeData(
                    color: Colors
                        .lightGreenAccent)), // change the icon color to red
            child: Icon(Icons.arrow_back),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor:
                    Colors.lightGreenAccent), // change the text color to red
            onPressed: _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                    child: Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage: Image.file(_image!).image,
                          )
                        : CircleAvatar(
                            radius: 60,
                            backgroundColor: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white // Dark mode background color
                                : Colors
                                    .grey[600], // Light mode background color
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.black // Dark mode icon color
                                  : Colors.white, // Light mode icon color
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.grey[300] // Dark mode container color
                                : Colors.black, // Light mode container color
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.camera_alt,
                            size: 20,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black // Dark mode icon color
                                    : Colors.white, // Light mode icon color
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(20), // circular border
                    ),
                    filled: true, // fill the background with a color
                    fillColor: Colors.white, // background color
                    labelStyle: TextStyle(
                      color: Colors.blue, // change the hint text color to grey
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(20), // circular border
                    ),
                    filled: true, // fill the background with a color
                    fillColor: Colors.white, // background color
                    labelStyle: TextStyle(
                      color: Colors.blue, // change the hint text color to grey
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(20), // circular border
                    ),
                    filled: true, // fill the background with a color
                    fillColor: Colors.white, // background color
                    labelStyle: TextStyle(
                      color: Colors.blue, // change the hint text color to grey
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(20), // circular border
                    ),
                    filled: true, // fill the background with a color
                    fillColor: Colors.white, // background color
                    labelStyle: TextStyle(
                      color: Colors.blue, // change the hint text color to grey
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  child: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userEmail = _auth.currentUser!.email;
      if (_image != null) {
        final ref =
            _storage.ref().child('profilePictures').child('$userEmail.jpg');
        await ref.putFile(_image!);
        final url = await ref.getDownloadURL();

        // Check if the "profile" collection exists
        final collectionRef = _firestore.collection('profile');
        final snapshot = await collectionRef.doc(userEmail).get();
        if (!snapshot.exists) {
          // If the document doesn't exist, create it
          await collectionRef.doc(userEmail).set({
            'profilePicture': url,
            'name': _nameController.text,
            'username': _usernameController.text,
            'email': userEmail,
          });
        } else {
          // If the document exists, update it
          await collectionRef.doc(userEmail).update({
            'profilePicture': url,
            'name': _nameController.text,
            'username': _usernameController.text,
          });
        }
      } else {
        final collectionRef = _firestore.collection('profile');
        final snapshot = await collectionRef.doc(userEmail).get();
        if (!snapshot.exists) {
          // If the document doesn't exist, create it
          await collectionRef.doc(userEmail).set({
            'name': _nameController.text,
            'username': _usernameController.text,
            'email': userEmail,
          });
        } else {
          // If the document exists, update it
          await collectionRef.doc(userEmail).update({
            'name': _nameController.text,
            'username': _usernameController.text,
          });
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile Updated'),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
      );
    }
  }
}
