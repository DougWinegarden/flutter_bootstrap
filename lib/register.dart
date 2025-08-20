import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Twoodler/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Twoodler/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class RegisterPage extends StatelessWidget{

  var emailController = TextEditingController();
  var passController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    Future<void> registerUser(String email, String password) async {
      try {
        // Check if Firebase is initialized
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
        }

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        if (userCredential.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Registration Success!"))
          );
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage())
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'The account already exists for that email.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          default:
            errorMessage = 'An error occurred: ${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage))
        );
        print('FirebaseAuthException: ${e.code} - ${e.message}');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred'))
        );
        print('Other error: $e');
      }
    }

    return Scaffold(
      //title: 'Flutter Firebase Bootstrap DW',
      appBar: AppBar(title: const Text('Registration Page')),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.all(50.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Twoodler!", style: TextStyle(color: Colors.black, fontSize:20, fontWeight: FontWeight.w600),),
            Text('Create a new account:'),
            SizedBox(height: 35,),
            TextField(controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter Email"
                ),
            ),
            SizedBox(height: 50,),
          TextField(controller: passController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter Password"
            ),
          ),
            SizedBox(height: 35,),
            ElevatedButton(onPressed: () async {

              String mail = emailController.text.trim();
              String pass = passController.text.trim();
              
              if(mail.isEmpty || pass.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter All the Fields")));
              }
              else
                {
                  registerUser(mail, pass);
                  // try{
                  //   await FirebaseAuth.instance.createUserWithEmailAndPassword(email: mail, password: pass).then((value){
                  //
                  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration Success!")));
                  //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
                  //   });
                  // } on FirebaseAuthException catch (e) {
                  //   print('FirebaseAuthException: ${e.code} - ${e.message}');
                  // } catch (e) {
                  //   print('Other error: $e');
                  // }

                  //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Register")));

                }

            },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: Text("Register", style: TextStyle(fontSize: 10, color: Colors.white),)),

              SizedBox(height: 25,),
              InkWell(
                onTap: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                },
                child:Text("Already have an account? Click Here", style: TextStyle(color: Colors.blueAccent)),
              ),

          ],
        ),
      ),
    );
  }


}

