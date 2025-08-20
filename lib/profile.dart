import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Twoodler/notes.dart';
import 'package:Twoodler/home.dart';
import 'package:Twoodler/login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? currentUser;
  int totalNotes = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getTotalNotesCount();
  }

  void getCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> getTotalNotesCount() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (currentUser?.email != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Twoods')
            .where('User', isEqualTo: currentUser!.email)
            .get();

        setState(() {
          totalNotes = querySnapshot.docs.length;
          isLoading = false;
        });
      } else {
        setState(() {
          totalNotes = 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error getting twood count: $e');
      setState(() {
        totalNotes = 0;
        isLoading = false;
      });
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login page or home page
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => LoginPage()),
      //   (route) => false,
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed out successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  String formatEmail(String? email) {
    if (email == null || email.isEmpty) return 'No email';
    return email;
  }

  String getInitials(String? email) {
    if (email == null || email.isEmpty) return 'U';
    String firstLetter = email.substring(0, 1).toUpperCase();
    return firstLetter;
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: currentUser == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Text(
              'Not Logged In',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please log in to view your profile',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigate to login page
                // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text('Go to Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue.shade700],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    // Profile Picture/Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          getInitials(currentUser?.email),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // User Email
                    Text(
                      formatEmail(currentUser?.email),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Member since ${currentUser?.metadata.creationTime?.year ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stats Section
            Padding(
              padding: EdgeInsets.all(20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            color: Colors.blue,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Your Statistics',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Total Notes Count
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.note_alt_outlined,
                              size: 40,
                              color: Colors.blue,
                            ),
                            SizedBox(height: 10),
                            isLoading
                                ? CircularProgressIndicator()
                                : Text(
                              '$totalNotes',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              'Total Twoods',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Account Actions Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    // Refresh Stats
                    ListTile(
                      leading: Icon(Icons.refresh, color: Colors.green),
                      title: Text('Refresh Statistics'),
                      subtitle: Text('Update your twood count'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        getTotalNotesCount();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Statistics refreshed!')),
                        );
                      },
                    ),
                    Divider(height: 1),
                    // View My Notes
                    ListTile(
                      leading: Icon(Icons.list_alt, color: Colors.blue),
                      title: Text('View My Twoods'),
                      subtitle: Text('See all your submitted twoods'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to filtered notes page showing only user's notes
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FilteredNotesListPage(initialShowAllNotes: false),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1),
                    // Account Info
                    ListTile(
                      leading: Icon(Icons.info_outline, color: Colors.orange),
                      title: Text('Account Information'),
                      subtitle: Text('View account details'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Account Information'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${currentUser?.email ?? 'N/A'}'),
                                SizedBox(height: 8),
                                Text('User ID: ${currentUser?.uid ?? 'N/A'}'),
                                SizedBox(height: 8),
                                Text('Account Created: ${currentUser?.metadata.creationTime?.toString().split(' ')[0] ?? 'Unknown'}'),
                                SizedBox(height: 8),
                                Text('Last Sign In: ${currentUser?.metadata.lastSignInTime?.toString().split(' ')[0] ?? 'Unknown'}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Sign Out Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    bool? confirmSignOut = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Sign Out'),
                        content: Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            //confirmSignOut = true,
                            onPressed: () async{
                                await signOut();
                              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute( builder: (ctx) => LoginPage()), (route) => false);

                            },

                                 //Navigator.pop(context, true),
                            child: Text('Sign Out'),
                          ),
                        ],
                      ),
                    );

                    if (confirmSignOut == true) {
                      await signOut();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),)
    );
  }
}