import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:Twoodler/home.dart';

class FilteredNotesListPage extends StatefulWidget {
  final bool initialShowAllNotes;

  const FilteredNotesListPage({
    Key? key,
    this.initialShowAllNotes = true,
  }) : super(key:key);

  @override
  _FilteredNotesListPageState createState() => _FilteredNotesListPageState();
}

class _FilteredNotesListPageState extends State<FilteredNotesListPage> {
  late bool showAllNotes; // true for "All Notes", false for "My Notes"

  // Get the current user's email
  String? getCurrentUserEmail() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.email;
  }

  // Delete a note from Firestore
  Future<void> deleteNote(String documentId, String noteText) async {
    try {
      await FirebaseFirestore.instance
          .collection('Twoods')
          .doc(documentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Twood deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting twood: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error deleting twood: $e');
    }
  }

  // Show delete confirmation dialog
  Future<bool> showDeleteConfirmation(String noteText) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete twood'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this twood?'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                noteText.length > 100
                    ? '${noteText.substring(0, 100)}...'
                    : noteText,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  // Get the appropriate stream based on filter
  Stream<QuerySnapshot> getNotesStream() {
    if (showAllNotes) {
      // Show all notes
      return FirebaseFirestore.instance
          .collection('Twoods')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      // Show only current user's notes
      String? userEmail = getCurrentUserEmail();
      if (userEmail == null) {
        // Return empty stream if no user is logged in
        return Stream.empty();
      }
      return FirebaseFirestore.instance
          .collection('Twoods')
          .where('User', isEqualTo: userEmail)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize with the passed value
    showAllNotes = widget.initialShowAllNotes;
  }
  Widget build(BuildContext context) {
    String? currentUserEmail = getCurrentUserEmail();
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            // Navigate to home page when back button is pressed
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(showAllNotes ? 'All Twoods' : 'My Twoods'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              // Filter buttons
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showAllNotes = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: showAllNotes ? Colors.blue : Colors.grey[300],
                          foregroundColor: showAllNotes ? Colors.white : Colors.black87,
                          elevation: showAllNotes ? 2 : 0,
                        ),
                        child: Text('All Twoods'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: currentUserEmail != null ? () {
                          setState(() {
                            showAllNotes = false;
                          });
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !showAllNotes ? Colors.blue : Colors.grey[300],
                          foregroundColor: !showAllNotes ? Colors.white : Colors.black87,
                          elevation: !showAllNotes ? 2 : 0,
                        ),
                        child: Text('My Twoods'),
                      ),
                    ),
                  ],
                ),
              ),

              // Notes list
              Expanded(
                child: currentUserEmail == null && !showAllNotes
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Please log in',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Log in to view your twoods',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
                    : StreamBuilder<QuerySnapshot>(
                  stream: getNotesStream(),
                  builder: (context, snapshot) {
                    // Handle loading state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    // Handle error state
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Error loading twoods',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please try again later',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    // Handle empty state
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              showAllNotes ? 'No twoods yet' : 'No twoods found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              showAllNotes
                                  ? 'Be the first to add a twood!'
                                  : 'You haven\'t added any twoods yet',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    // Display the list of notes
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = snapshot.data!.docs[index];
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                        String noteText = data['Text'] ?? 'No text available';
                        String userEmail = data['User'] ?? 'Unknown user';
                        Timestamp? timestamp = data['timestamp'] as Timestamp?;

                        String formattedDate = 'Unknown time';
                        if (timestamp != null) {
                          formattedDate = DateFormat('MMM d, yyyy - h:mm a')
                              .format(timestamp.toDate());
                        }

                        // Check if this note belongs to the current user
                        bool isMyNote = userEmail == currentUserEmail;

                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Text(
                              noteText,
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(formattedDate),
                                if (showAllNotes && isMyNote)
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Your twood',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // Add delete functionality only for user's own notes
                            trailing: (isMyNote)
                                ? PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  bool confirmDelete = await showDeleteConfirmation(noteText);
                                  if (confirmDelete) {
                                    await deleteNote(document.id, noteText);
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                                : null,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Optional: Add floating action button to add new notes
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigate to your data submission page
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            child: Icon(Icons.add),
            tooltip: 'Add New Twood',
          ),)
    );
  }
}