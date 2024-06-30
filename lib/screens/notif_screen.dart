import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationData {
  final String postId;
  final String postTitle;
  final String comment;
  final String commenterEmail;

  NotificationData({
    required this.postId,
    required this.postTitle,
    required this.comment,
    required this.commenterEmail,
  });
}

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
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
      body: NotificationList(),
    );
  }
}

class NotificationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Stream is in waiting state');
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('No data available');
          return Center(child: Text('No notifications available'));
        }

        // If all conditions are met, display ListView of notifications
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return NotificationTile(
              notification: NotificationData(
                postId: data['postId'],
                postTitle: data['postTitle'],
                comment: data['comment'],
                commenterEmail: data['commenterEmail'],
              ),
              notificationDocId: doc.id, // Pass the document ID
            );
          }).toList(),
        );
      },
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationData notification;
  final String notificationDocId; // Document ID of the notification

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.notificationDocId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch the current user's email
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email!;

    // Check if the comment is from the current user
    bool isCurrentUserComment = notification.commenterEmail == currentUserEmail;

    return FutureBuilder(
      future: _getProfilePicture(notification.commenterEmail),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String profilePictureUrl = snapshot.data as String;
          return Dismissible(
            key: Key(notificationDocId),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (direction) {
              // Delete the notification document from Firestore
              FirebaseFirestore.instance
                  .collection('notifications')
                  .doc(notificationDocId)
                  .delete()
                  .then((value) {
                print('Notification deleted successfully');
              }).catchError((error) {
                print('Failed to delete notification: $error');
              });
            },
            child: isCurrentUserComment
                ? SizedBox
                    .shrink() // Hide the tile if it's the current user's comment
                : ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(profilePictureUrl),
                    ),
                    title: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text: '${notification.commenterEmail} ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[300] // Dark mode text color
                                  : Colors.black, // Light mode text color
                            ),
                          ),
                          TextSpan(
                            text: 'Commented on "${notification.postTitle}"',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[300] // Dark mode text color
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      notification.comment,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize
                          .min, // Ensure the delete button is aligned properly
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: 40, // Set the width of the SizedBox
                            height: 40, // Set the height of the SizedBox
                            child: IconButton(
                              icon: Icon(Icons.delete,
                                  size: 24), // Change the size of the icon here
                              onPressed: () {
                                // Delete the notification document from Firestore
                                FirebaseFirestore.instance
                                    .collection('notifications')
                                    .doc(notificationDocId)
                                    .delete()
                                    .then((value) {
                                  print('Notification deleted successfully');
                                }).catchError((error) {
                                  print(
                                      'Failed to delete notification: $error');
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        } else {
          return SizedBox
              .shrink(); // Hide the tile if profile picture data is not available yet
        }
      },
    );
  }

  Future<String> _getProfilePicture(String userEmail) async {
    final collectionRef = FirebaseFirestore.instance.collection('profile');
    final snapshot = await collectionRef.doc(userEmail).get();

    if (snapshot.exists) {
      return snapshot.get('profilePicture') ?? '';
    } else {
      return ''; // Return a default profile picture URL or an empty string
    }
  }
}
