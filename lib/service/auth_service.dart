import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learning_firebase/model/user.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _facebookLogin = new FacebookLogin();

  ////////////////////////// creating/retrieving Firebase user method start ///////////////////////////
  // create user obj based on firebase user
  Future<User> _userFromFirebaseUser(FirebaseUser firebaseUser) async {
    if (firebaseUser != null) {
      // Check is already sign up
      // QuerySnapshot is returned from a collection query, and allows you to inspect the collection
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();

      // DocumentSnapshot is returned from a query, or by accessing the document directly
      // Even if no document exists in the database, a snapshot will always be returned.
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'nickname': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid
        });

        var newUser = {
          'id': documents[0].data['id'],
          'nickname': documents[0].data['nickname'],
          'photoUrl': documents[0].data['photoUrl'],
        };

        print('newUser ----- $newUser');

        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('userData', json.encode(newUser));
      } else {
        var oldUser = {
          'id': documents[0].data['id'],
          'nickname': documents[0].data['nickname'],
          'photoUrl': documents[0].data['photoUrl'],
        };

        print('oldUser ----- $oldUser');

        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('userData', json.encode(oldUser));
      }
      return User(id: firebaseUser.uid);
    }
    return null;
  }
  ////////////////////////// creating/retrieving Firebase user method start ///////////////////////////

  // // auth change user stream
  // Stream<User> get user {
  //   return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  // }

  ///////////////////////////// register with email and password method start /////////////////////////
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          // built in Firebase user auth method
          email: email,
          password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
  ///////////////////////////// register with email and password method end /////////////////////////

  ///////////////////////////// sign in  with email and password method start //////////////////////////
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
      // } catch (error) {
    } on PlatformException catch (e) {
      print('''
      PlatformException caught on signInWithEmailAndPassword
        ${e.message}
        ''');
    } on AuthException catch (error) {
      print(error.toString());
      print('''
    caught firebase auth exception\n
    ${error.code}\n
    ${error.message}
  ''');
      return null;
    }
  }
  ///////////////////////////// sign in  with email and password method end //////////////////////////

  //////////////////////////// sign out method start ////////////////////////////
  Future signOut() async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      _googleSignIn.isSignedIn().then((s) async {
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect().catchError((onError) {
          print(onError);
          return null;
        });

        print("Google User Signed Out");
        localStorage.clear();

        return;
      });

      _facebookLogin.isLoggedIn.then((s) async {
        await _facebookLogin.logOut();

        print("Facebook User Signed Out");

        localStorage.clear();
        return;
      });

      localStorage.clear();
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
  //////////////////////////// sign out method end ////////////////////////////

  /////////////////////////// signInWithGoogle method start /////////////////////////
  Future signInWithGoogle() async {
    // try {

    // hold the instance of the authenticated user
    FirebaseUser user;

    // flag to check whether we're signed in already
    bool isSignedIn = await _googleSignIn.isSignedIn();

    if (isSignedIn) {
      // if so, return the current user
      user = await _auth.currentUser();
    } else {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      // .catchError((onError) => print('onError'));

      // Return null to prevent further exceptions if googleSignInAccount is null
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // get the credentials to (access / id token)
      // to sign in via Firebase Authentication
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      user = (await _auth.signInWithCredential(credential)).user;
    }

    return _userFromFirebaseUser(user);
    // }
    //  on PlatformException catch (err) {
    //   // Checks for type PlatformException
    //   if (err.code == 'sign_in_canceled') {
    //     // Checks for sign_in_canceled exception
    //     print(err.toString());
    //   }
    // }
    //  on PlatformException catch (e) {
    //   print(e.message);
    // } on AuthException catch (error) {} catch (error) {
    //   print(error.toString());
    //   print('''
    //         caught firebase exception\n
    //         ${error.code}\n
    //         ${error.message}
    //        ''');
    // }
  }
  /////////////////////////// signInWithGoogle method end /////////////////////////

  ////////////////////////// signInWithFacebook method start ///////////////////////
  Future signInWithFacebook() async {
    // hold the instance of the authenticated user
    FirebaseUser user;

    // Trigger the sign-in flow
    final FacebookLoginResult result =
        await _facebookLogin.logIn(['email', 'public_profile']);

    print('FacebookLoginResult -------------- $result');

    // Return null to prevent further exceptions if googleSignInAccount is null
    if (result.status != FacebookLoginStatus.loggedIn) return null;

    // Create a credential from the access token
    final AuthCredential facebookAuthCredential =
        FacebookAuthProvider.getCredential(
      accessToken: result.accessToken.token,
    );

    user = (await _auth.signInWithCredential(facebookAuthCredential)).user;
    // Once signed in, return the UserCredential
    return _userFromFirebaseUser(user);
  }
  ////////////////////////// signInWithFacebook method end ///////////////////////

  ///////////////////////// signInWithPhone method start /////////////////////////
  Future signInWithPhone(String verId, String otp) async {
    // // hold the instance of the authenticated user
    // FirebaseUser user;
    // String verId;

    // await _auth.verifyPhoneNumber(
    //   timeout: Duration(seconds: 60),
    //   // phoneNumber: '+880 1785-671700',
    //   phoneNumber: phoneNumber,
    //   verificationCompleted: (AuthCredential phoneAuthCredential) async {
    //     // ANDROID ONLY!

    //     // Sign the user in (or link) with the auto-generated credential
    //     await _auth.signInWithCredential(phoneAuthCredential);

    //     user = (await _auth.signInWithCredential(phoneAuthCredential)).user;
    //     // Once signed in, return the UserCredential
    //     return _userFromFirebaseUser(user);
    //   },
    //   verificationFailed: (AuthException e) {
    //     if (e.code == 'invalid-phone-number') {
    //       print('The provided phone number is not valid.');
    //     }
    //     user = null;
    //     // Handle other errors
    //   },
    //   codeSent: (String verificationId, [int resendToken]) async {
    //     // Update the UI - wait for the user to enter the SMS code
    //     // String smsCode = '654321';
    //     String smsCode = otp;

    //     // Create a PhoneAuthCredential with the code
    //     AuthCredential phoneAuthCredential = PhoneAuthProvider.getCredential(
    //         smsCode: smsCode, verificationId: verificationId);

    //     // Sign the user in (or link) with the credential
    //     await _auth.signInWithCredential(phoneAuthCredential);

    //     user = (await _auth.signInWithCredential(phoneAuthCredential)).user;
    //     // Once signed in, return the UserCredentialF
    //     return _userFromFirebaseUser(user);
    //   },
    //   codeAutoRetrievalTimeout: (String verificationId) {
    //     // Auto-resolution timed out...
    //     verificationId = verificationId;
    //     verId = verificationId;
    //     print(verificationId);
    //     print("Timeout");
    //   },
    // );


      print('smsCode: $otp //////////////// verificationId: $verId');

    // Create a PhoneAuthCredential with the code
    AuthCredential phoneAuthCredential = PhoneAuthProvider.getCredential(
        // smsCode: '654321',
        smsCode: otp,
        verificationId: verId);
    // 'AM5PThBOi9q-EobB9k2TDCtO5sOJjBZTRCTf7CGiFYgKHIKgOlmupmkhSa8ai6G0tYPu9LBOmGHbNUU9FVqBpECQcPOm_oul0a0WBdLnzAas2WpcOYWvEnIrpFiSWQkCvp_caGp6dKcAUnl5D85eZk8Go5yIunm84g');
    return _userFromFirebaseUser(
        (await _auth.signInWithCredential(phoneAuthCredential)).user);
  }
  ///////////////////////// signInWithPhone method end //////////////////////////
}
