import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haidenjem/screens/detail_screen.dart';

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
        title: Text('Notifications'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
    return Dismissible(
      key: Key(notificationDocId), // Use notification's document ID as key
      direction: DismissDirection.endToStart, // Swipe from right to left
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
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage('https://via.placeholder.com/150'),
        ),
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                text: '${notification.commenterEmail} ',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: 'commented on "${notification.postTitle}"',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        subtitle: Text(
          notification.comment,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize:
              MainAxisSize.min, // Ensure the delete button is aligned properly
          children: [
            Text(
              '', // Replace with time ago calculation
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 4),
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
                      print('Failed to delete notification: $error');
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
