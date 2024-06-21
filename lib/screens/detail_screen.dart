import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haidenjem/screens/edit_post.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  final String documentId;
  final String imageUrl;
  final String title;
  final String description;
  final Timestamp timestamp;
  final String userEmail;
  final double latitude;
  final double longitude;

  const DetailScreen({
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
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Post'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPostScreen(
                    documentId: widget.documentId,
                    imageUrl: widget.imageUrl,
                    title: widget.title,
                    description: widget.description,
                    timestamp: widget.timestamp,
                    userEmail: widget.userEmail,
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150',
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        widget.userEmail,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    width: screenWidth,
                    height: screenWidth, // Aspect ratio
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _likeData();
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.comment),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    widget.description,
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _openMaps(widget.latitude, widget.longitude);
                        },
                        icon: Icon(Icons.location_on),
                      ),
                      Expanded(
                        child: Text(
                          'Latitude: ${widget.latitude}, Longitude: ${widget.longitude}',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Timestamp: ${DateFormat.yMMMd().add_jm().format(widget.timestamp.toDate())}',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  SizedBox(height: 16.0),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.documentId)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        default:
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...snapshot.data!.docs.map((comment) {
                                return ListTile(
                                  title: Text(comment['comment']),
                                  subtitle: Text('By: ${comment['userEmail']}'),
                                  trailing: (comment['userEmail'] ==
                                          FirebaseAuth
                                              .instance.currentUser?.email)
                                      ? IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {},
                                        )
                                      : null,
                                );
                              }).toList(),
                            ],
                          );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMaps(double latitude, double longitude) async {
    String mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    try {
      if (await canLaunch(mapsUrl)) {
        await launch(mapsUrl);
      } else {
        throw 'Could not launch $mapsUrl';
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _likeData() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final String userId =
        'current_user_id'; // Replace with the current user's ID

    final DocumentSnapshot favoriteDoc = await _firestore
        .collection('favorites')
        .doc(userId)
        .collection('posts')
        .doc(widget.documentId)
        .get();

    if (favoriteDoc.exists) {
      await _firestore
          .collection('favorites')
          .doc(userId)
          .collection('posts')
          .doc(widget.documentId)
          .delete();

      setState(() {
        isFavorite = false;
      });

      print('Post removed from favorites');
    } else {
      await _firestore
          .collection('favorites')
          .doc(userId)
          .collection('posts')
          .doc(widget.documentId)
          .set({
        'postId': widget.documentId,
        'title': widget.title,
        'imageUrl': widget.imageUrl,
        'description': widget.description,
        'timestamp': widget.timestamp,
        'userEmail': widget.userEmail,
        'latitude': widget.latitude,
        'longitude': widget.longitude,
      });

      setState(() {
        isFavorite = true;
      });

      print('Post added to favorites');
    }
  }
}
