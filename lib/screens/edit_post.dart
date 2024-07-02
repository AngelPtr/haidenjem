import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haidenjem/main.dart';

class EditPostScreen extends StatefulWidget {
  final String documentId;
  final String imageUrl;
  final String title;
  final String description;
  final Timestamp timestamp;
  final String userEmail;
  final double latitude;
  final double longitude;

  EditPostScreen({
    required this.documentId,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.userEmail,
    required this.latitude,
    required this.longitude,
  });

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  String _newTitle = '';
  String _newDescription = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Post',
          style: TextStyle(
              color: Colors.lightGreenAccent), // change the title color to red
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black // Dark mode
            : Colors.green[900], // Light mode
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
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Image.network(widget.imageUrl),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: widget.title,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: const TextStyle(
                      color: Colors.blue, // change the hint text color to grey
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 9, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    filled: true, // fill the background with a color
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) => _newTitle = value!,
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: widget.description,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(
                      color: Colors.blue, // change the hint text color to grey
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 9, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    filled: true, // fill the background with a color
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) => _newDescription = value!,
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // text color
                    elevation: 5, // elevation
                    padding: EdgeInsets.all(16), // padding
                    textStyle: TextStyle(fontSize: 18), // text style
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      if (_auth.currentUser!.email == widget.userEmail) {
                        await _firestore
                            .collection('Post')
                            .doc(widget.documentId)
                            .update({
                          'judul': _newTitle,
                          'deskripsi': _newDescription,
                        });

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BottomNavBar()),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Post Succesfully Updated'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You can only edit your own posts'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Update Post'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red, // text color
                    elevation: 5, // elevation
                    padding: EdgeInsets.all(16), // padding
                    textStyle: TextStyle(fontSize: 18), // text style
                  ),
                  onPressed: () async {
                    if (_auth.currentUser!.email == widget.userEmail) {
                      await _firestore
                          .collection('Post')
                          .doc(widget.documentId)
                          .delete();

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNavBar()),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Post Deleted'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('You can only delete your own posts'),
                        ),
                      );
                    }
                  },
                  child: Text('Delete Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
