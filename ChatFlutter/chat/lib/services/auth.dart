import 'package:chat/helpers/shared_preferences_helper.dart';
import 'package:chat/services/database.dart';
import 'package:chat/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  getCurrentUser() async{
    return await _firebaseAuth.currentUser;
  }

  signInWithGoogle(BuildContext context) async{

    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken
    );

    UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);
    User userDetails = userCredential.user;

    if(userDetails != null){
      var username = userDetails.email.replaceAll(("@gmail.com"), "");

      SharedPreferenceHelper().saveUserEmail(userDetails.email);
      SharedPreferenceHelper().saveUserId(userDetails.uid);
      SharedPreferenceHelper().saveUserProfile(userDetails.photoURL);
      SharedPreferenceHelper().saveUserDisplayName(userDetails.displayName);
      SharedPreferenceHelper().saveUserName(username);

      Map<String, dynamic> userInfo = {
        "email": userDetails.email,
        "username": username,
        "name": userDetails.displayName,
        "profile": userDetails.photoURL
      };
      DatabaseMethods().addUserInfo(userDetails.uid, userInfo).then(
          (value){
            Navigator.pushReplacement(context, MaterialPageRoute(builder:
            (context) => Home()));
          }
      );
    }
  }

  Future signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}