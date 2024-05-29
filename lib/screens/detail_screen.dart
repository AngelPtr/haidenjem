import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatelessWidget {
  final String documentId;
  final String imageUrl;
  final String title;
  final String description;
  final Timestamp timestamp;
  final String userEmail;

  const DetailScreen({
    required this.documentId,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 200,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'judul: $title',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Deskripsi: $description',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Timestamp: ${DateFormat.yMMMd().add_jm().format(timestamp.toDate())}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Posted by: $userEmail',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
