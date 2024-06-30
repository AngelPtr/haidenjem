import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haidenjem/screens/edit_post.dart';
import 'package:haidenjem/screens/notif_screen.dart';
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
        title: const Text(
          'Post',
          style: TextStyle(
              color: Colors.lightGreenAccent), // change the title color to red
        ),
        automaticallyImplyLeading: false,
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
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications,
                  color:
                      Colors.lightGreenAccent, // Change the icon color to blue
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          )
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
                      FutureBuilder(
                        future: _getProfilePicture(widget.userEmail),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              String profilePictureUrl =
                                  snapshot.data as String;
                              return CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    NetworkImage(profilePictureUrl),
                              );
                            } else {
                              return CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  'https://via.placeholder.com/150',
                                ),
                              );
                            }
                          } else {
                            return CircularProgressIndicator(); // Show a loading indicator while the future is loading
                          }
                        },
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
                            onPressed: () {
                              _commentData();
                            },
                            icon: Icon(Icons.comment),
                          ),
                        ],
                      ),
                      FirebaseAuth.instance.currentUser?.email ==
                              widget.userEmail
                          ? IconButton(
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
                            )
                          : Container(), // Don't show the edit button if it's not the current user's post
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
                                          onPressed: () {
                                            _deleteComment(comment.id);
                                          },
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

  Future<String> _getProfilePicture(String userEmail) async {
    final collectionRef = FirebaseFirestore.instance.collection('profile');
    final snapshot = await collectionRef.doc(userEmail).get();

    if (snapshot.exists) {
      return snapshot.get('profilePicture') ?? '';
    } else {
      return 'https://via.placeholder.com/150'; // Return a default profile picture URL if the user document doesn't exist
    }
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

  void _commentData() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Comment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Enter your comment',
                  labelStyle: TextStyle(
                    color: Colors.blue, // change the hint text color to grey
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // border radius
                    borderSide: BorderSide(
                        width: 2, color: Colors.blue), // border style
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        width: 2,
                        color: Colors.blueAccent), // focused border style
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 2, color: Colors.blue),
                  ),
                  filled: true, // fill the background with a color
                  fillColor: Colors.white,
                ),
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // text color
                  elevation: 5, // elevation
                  padding: EdgeInsets.all(16), // padding
                  textStyle: TextStyle(fontSize: 18), // text style
                ),
                onPressed: () {
                  _saveComment(_commentController.text);
                },
                child: Text('Post Comment'),
              )
            ],
          ),
        );
      },
    );
  }

  void _saveComment(String commentText) async {
    if (commentText.isNotEmpty) {
      final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
      if (currentUserEmail != null) {
        final docRef = await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.documentId)
            .collection('comments')
            .add({
          'userEmail': currentUserEmail,
          'comment': commentText,
          'timestamp': Timestamp.now(),
        });

        await _saveNotification(
          docRef.id,
          widget.documentId,
          widget.title,
          commentText,
          currentUserEmail,
        );

        _commentController.clear(); // Clear text field after posting comment
        setState(() {}); // Trigger rebuild

        print('Comment saved');
      } else {
        print('User not authenticated');
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment Posted'),
        ),
      );
    } else {
      print('Comment text is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment text is empty'),
        ),
      );
    }
  }

  Future<void> _saveNotification(String commentId, String postId,
      String postTitle, String commentText, String commenterEmail) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'postId': postId,
        'postTitle': postTitle,
        'comment': commentText,
        'commenterEmail': commenterEmail,
        'commentId': commentId,
        'timestamp': Timestamp.now(),
      });
      print('Notification saved');
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  void _deleteComment(String commentId) async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.documentId)
          .collection('comments')
          .doc(commentId)
          .get();

      if (doc.exists) {
        final commentEmail = doc['userEmail'];

        if (currentUserEmail == commentEmail) {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.documentId)
              .collection('comments')
              .doc(commentId)
              .delete();

          print('Comment deleted');
          setState(() {}); // Trigger rebuild
        } else {
          print('Current user cannot delete this comment');
        }
      } else {
        print('Comment not found');
      }
    } catch (e) {
      print('Error deleting comment: $e');
    }
  }
}
