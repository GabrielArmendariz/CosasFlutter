import 'package:chat/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Firebase Chat App')),
      body: Center(child:
      GestureDetector(
        onTap: (){
          AuthMethods().signInWithGoogle(context);
        },
        child: Container(
            decoration: BoxDecoration(
              color: Color(0xffDB4437),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Sign in with Google",
                style: TextStyle(fontSize: 16)
            )
          ),
        )
      ),
    );
  }
}
