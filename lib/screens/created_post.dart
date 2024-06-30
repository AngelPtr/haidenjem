import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haidenjem/screens/detail_screen.dart';
import 'package:haidenjem/screens/edit_post.dart';

class CreatedPostScreen extends StatefulWidget {
  @override
  _CreatedPostScreenState createState() => _CreatedPostScreenState();
}

class _CreatedPostScreenState extends State<CreatedPostScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Created Posts',
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Post')
            .where('user_email', isEqualTo: _auth.currentUser!.email)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                final imageUrl = document['url'];
                final title = document['judul'];
                final description = document['deskripsi'];

                return Card(
                  child: ListTile(
                    title: Text(title),
                    subtitle: Text(description),
                    leading: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPostScreen(
                              documentId: document.id,
                              imageUrl: imageUrl,
                              title: title,
                              description: description,
                              timestamp: document['timestamp'],
                              userEmail: document['user_email'],
                              latitude: document['latitude'],
                              longitude: document['longitude'],
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            documentId: document.id,
                            imageUrl: imageUrl,
                            title: title,
                            description: description,
                            timestamp: document['timestamp'],
                            userEmail: document['user_email'],
                            latitude: document['latitude'],
                            longitude: document['longitude'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
