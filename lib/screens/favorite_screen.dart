import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haidenjem/main.dart';
import 'package:haidenjem/screens/detail_screen.dart';
import 'package:haidenjem/screens/home_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = 'current_user_id'; // Replace with the current user's ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Favorite',
          style: TextStyle(
              color: Colors.lightGreenAccent), // change the title color to red
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black // Dark mode
            : Colors.green[900], // Light mode
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('favorites')
            .doc(userId)
            .collection('posts')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    data['imageUrl'],
                  ),
                ),
                title: Text(data['title']),
                subtitle: Text(data['description']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        documentId: document.id,
                        imageUrl: data['imageUrl'],
                        title: data['title'],
                        description: data['description'],
                        timestamp: data['timestamp'],
                        userEmail: data['userEmail'],
                        latitude: data['latitude'],
                        longitude: data['longitude'],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
