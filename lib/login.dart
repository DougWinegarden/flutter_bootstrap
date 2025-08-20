import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Twoodler/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Twoodler/home.dart';

class LoginPage extends StatelessWidget{

  var emailController = TextEditingController();
  var passController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome back to Twoodler!", style: TextStyle(color: Colors.black, fontSize:20, fontWeight: FontWeight.w600),),
            Text('Login to your existing account:'),
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
            SizedBox(height: 50,),
            ElevatedButton(onPressed: () async {

              String mail = emailController.text.trim();
              String pass = passController.text.trim();

              if(mail.isEmpty || pass.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter All the Fields")));
              }
              else
              {
                try{
                  await FirebaseAuth.instance.signInWithEmailAndPassword(email: mail, password: pass).then((value){

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Success!")));
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
                  });
                }catch(err){
                  print(err);
                }
                //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logging in...")));
              }

            },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: Text("Login", style: TextStyle(fontSize: 10, color: Colors.white),)),
            SizedBox(height: 25,),
            InkWell(
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>RegisterPage()));
              },
              child:Text("New User? Click Here", style: TextStyle(color: Colors.blueAccent)),
            ),

          ],
        ),
      ),
    );
  }
}