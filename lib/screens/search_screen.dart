import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haidenjem/screens/detail_screen.dart';
import 'package:haidenjem/screens/home_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? _searchStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            ); // Return to previous screen (home screen)
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _search();
              },
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 9, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(50),
                ),
                filled: true, // fill the background with a color
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: _searchStream == null
                ? Center(child: Text('Search The Image Title'))
                : StreamBuilder<QuerySnapshot>(
              stream: _searchStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];
                        final imageUrl = documentSnapshot['url'];
                        final title = documentSnapshot['judul'];
                        final description = documentSnapshot['deskripsi'];

                        return Container(
                          decoration: BoxDecoration(
                            border:
                            Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                    documentId: documentSnapshot.id,
                                    imageUrl: imageUrl,
                                    title: title,
                                    description: description,
                                    timestamp:
                                    documentSnapshot['timestamp'],
                                    userEmail:
                                    documentSnapshot['user_email'],
                                    latitude:
                                    documentSnapshot['latitude'],
                                    longitude:
                                    documentSnapshot['longitude'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _search() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _searchStream = null;
      } else {
        _searchStream = _firestore
            .collection('Post')
            .where('judul', isGreaterThanOrEqualTo: _searchController.text)
            .where('judul',
            isLessThanOrEqualTo: _searchController.text + '\uf8ff')
            .snapshots();
      }
    });
  }
}
