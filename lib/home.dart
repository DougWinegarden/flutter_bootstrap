import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Twoodler/notes.dart';
import 'package:Twoodler/profile.dart';

class HomePage extends StatelessWidget{

  var NoteController = TextEditingController();
  //var DescController = TextEditingController();

  void _newNote(){

  }

  @override
  Widget build(BuildContext context) {
    Future<void> submitToFirestore(String textValue) async {
      try {
        // Get current user
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No user is currently logged in'))
          );
          return;
        }

        // Get Firestore instance
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Add document to Twoods collection
        await firestore.collection('Twoods').add({
          'Text': textValue.trim(),
          'User': currentUser.email,
          'timestamp': FieldValue.serverTimestamp(), // Optional: add timestamp
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data submitted successfully!'))
        );

        print('Document added successfully');

      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Firestore error: ${e.message}'))
        );
        print('FirebaseException: ${e.code} - ${e.message}');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred'))
        );
        print('Other error: $e');
      }
    }


    return Scaffold(
      appBar: AppBar(
        title: Text('Twoodler'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body:Padding(
        padding: EdgeInsets.all(50.0),
        //child: Center(
          //child:
          //padding: EdgeInsets.all(50.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ElevatedButton(onPressed: () async {
                //
                //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ProfilePage()));
                //
                // },
                //     style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                //     child: Text("Profile Page", style: TextStyle(fontSize: 10, color: Colors.white),)),
          Text("Post a Twood!", style: TextStyle(color: Colors.black, fontSize:20, fontWeight: FontWeight.w600),),
          SizedBox(height: 35,),
          TextField(controller: NoteController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter Twood"
            ),
          ),
          //SizedBox(height: 50,),
          // TextField(controller: DescController,
          //   decoration: InputDecoration(
          //       border: OutlineInputBorder(),
          //       labelText: "Enter Description"
          //   ),
          // ),
          SizedBox(height: 50,),
          ElevatedButton(onPressed: () async {

            String note = NoteController.text.trim();
            //String pass = DescController.text.trim();

            if(note.isEmpty){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter at least SOME text..")));
            }
            else
            {
              submitToFirestore(note);
            }

          },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: Text("Submit Twood", style: TextStyle(fontSize: 10, color: Colors.white),)),
                SizedBox(height: 50,),
                ElevatedButton(onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FilteredNotesListPage()));

                },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    child: Text("See All Twoods", style: TextStyle(fontSize: 10, color: Colors.white),)),
        ],
        ),

      ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _newNote,
        //   tooltip: 'New Note',
        //   child: const Icon(Icons.add),
        // )
    );
  }

}