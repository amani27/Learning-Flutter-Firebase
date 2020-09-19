import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learning_firebase/model/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _facebookLogin = new FacebookLogin();

  // create user obj based on firebase user
  Future<User> _userFromFirebaseUser(FirebaseUser firebaseUser) async {
    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
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
      }
      return  User(id: firebaseUser.uid);
    }
    return null;
    // return user != null ? User(uid: user.uid) : null;
  }

  // // auth change user stream
  // Stream<User> get user {
  //   return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  // }

  // register with email and password
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

  // sign in  with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (error) {
    // } on FirebaseAuthException catch (error) {
      print(error.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      _googleSignIn.isSignedIn().then((s) async {
        await _googleSignIn.signOut();

        print("Google User Signed Out");
        return;
      });

      _facebookLogin.isLoggedIn.then((s) async {
        await _facebookLogin.logOut();

        print("Facebook User Signed Out");
        return;
      });

      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // signInWithGoogle
  Future signInWithGoogle() async {
    // hold the instance of the authenticated user
    FirebaseUser user;
    // flag to check whether we're signed in already
    bool isSignedIn = await _googleSignIn.isSignedIn();
    if (isSignedIn) {
      // if so, return the current user
      user = await _auth.currentUser();
    } else {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
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
  }

  // signInWithFacebook
  Future signInWithFacebook() async {
    // hold the instance of the authenticated user
    FirebaseUser user;

    // Trigger the sign-in flow
    final FacebookLoginResult result =
        await _facebookLogin.logIn(['email', 'public_profile']);
    //     .then((result) async {
    // Create a credential from the access token
    final AuthCredential facebookAuthCredential =
        FacebookAuthProvider.getCredential(
      accessToken: result.accessToken.token,
    );

    //   switch (result.status) {
    //     case FacebookLoginStatus.error:
    //       print("Error");
    //       break;
    //     case FacebookLoginStatus.cancelledByUser:
    //       print("CancelledByUser");
    //       break;
    //     case FacebookLoginStatus.loggedIn:
    //       print("LoggedIn");
    //       user = (await _auth.signInWithCredential(facebookAuthCredential)).user;
    //       break;
    //   }
    // });

    user = (await _auth.signInWithCredential(facebookAuthCredential)).user;
    // Once signed in, return the UserCredential
    // return user;
    return _userFromFirebaseUser(user);
  }
}
