import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learning_firebase/model/user.dart';
import 'package:learning_firebase/service/auth_service.dart';
import 'package:learning_firebase/ui/home.dart';
import 'package:learning_firebase/ui/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  // text field state
  String email = '';
  String password = '';
  bool _loading = false;
  bool _googleLoading = false;

  String error = '';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _showDialog();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('LOGIN'),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email',
                    ),
                  ),
                  TextFormField(
                    validator: (val) => val.isEmpty ? 'Enter an email' : null,
                    onChanged: (val) {
                      setState(() => email = val);
                    },
                  ),
                  SizedBox(height: 20.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                    ),
                  ),
                  TextFormField(
                    obscureText: true,
                    validator: (val) => val.isEmpty ? 'Enter a password' : null,
                    onChanged: (val) {
                      setState(() => password = val);
                    },
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    width: 100,
                    child: RaisedButton(
                        color: Colors.lime[800],
                        child: _loading
                            ? CircularProgressIndicator()
                            : Text(
                                'Sign In',
                                style: TextStyle(color: Colors.white),
                              ),
                        onPressed: _loading
                            ? null
                            : () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  print('Sign In tapped');
                                  print(email);
                                  print(password);
                                  dynamic result =
                                      await _auth.signInWithEmailAndPassword(
                                          email, password);
                                  print(result);

                                  if (result == null) {
                                    setState(() {
                                      error = 'Invalid email/password!';
                                      _loading = false;
                                    });
                                    return;
                                  }

                                  SharedPreferences localStorage =
                                      await SharedPreferences.getInstance();
                                  localStorage.setString(
                                      'userData', json.encode(result));

                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => Home()));
                                }
                              }),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Don\'t have an account?',
                          // style: TextStyle(color: Colors.lime[900]),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.lime[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  ///////////////////// Social Authentication Options /////////////////////
                  Container(
                    width: 200,
                    child: RaisedButton(
                        color: Colors.lime[800],
                        child: _googleLoading
                            ? CircularProgressIndicator()
                            : Text(
                                'Sign in with Google',
                                style: TextStyle(color: Colors.white),
                              ),
                        onPressed: _googleLoading
                            ? null
                            : () async {
                                setState(() {
                                  _googleLoading = true;
                                });
                                print('Google Sign In tapped');
                                User user = await _auth.signInWithGoogle();

                                if (user == null) {
                                  setState(() {
                                    error = 'Invalid email/password!';
                                    _googleLoading = false;
                                  });
                                  return;
                                }

                                SharedPreferences localStorage =
                                    await SharedPreferences.getInstance();
                                localStorage.setString(
                                    'userData', json.encode(user));

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Home()));
                              }
                        // if (_formKey.currentState.validate()) {
                        // print(email);
                        // print(password);
                        // // dynamic result = await _auth.signInWithEmailAndPassword(
                        //     email, password);
                        // print(result);

                        // SharedPreferences localStorage =
                        //     await SharedPreferences.getInstance();
                        // localStorage.setString('userData', result.toString());

                        // if (result == null) {
                        //   setState(() {
                        //     error = 'Invalid email/password!';
                        //   });
                        //   return;
                        // }

                        // Navigator.of(context).pushReplacement(
                        //     MaterialPageRoute(builder: (context) => Home()));
                        // }
                        ),
                  ),

                  Container(
                    width: 200,
                    child: RaisedButton(
                        color: Colors.lime[800],
                        child: Text(
                          'Sign in with Facebook',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          // if (_formKey.currentState.validate()) {
                          print('Facebook Sign In tapped');
                          User user = await _auth.signInWithFacebook();

                          if (user == null) {
                            setState(() {
                              error = 'Invalid email/password!';
                              _googleLoading = false;
                            });
                            return;
                          }

                          SharedPreferences localStorage =
                              await SharedPreferences.getInstance();
                          localStorage.setString('userData', json.encode(user));

                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Home()));

//
//  var facebookLogin = FacebookLogin();
//     var facebookLoginResult =
//         await facebookLogin.logInWithReadPermissions(['email']);
//      switch (facebookLoginResult.status) {
//       case FacebookLoginStatus.error:
//         print("Error");
//         onLoginStatusChanged(false);
//         break;
//       case FacebookLoginStatus.cancelledByUser:
//         print("CancelledByUser");
//         onLoginStatusChanged(false);
//         break;
//       case FacebookLoginStatus.loggedIn:
//         print("LoggedIn");
//         onLoginStatusChanged(true);
//         break;
// }
//

                          // print(email);
                          // print(password);
                          // dynamic result = await _auth.signInWithEmailAndPassword(
                          //     email, password);
                          // print(result);

                          // SharedPreferences localStorage =
                          //     await SharedPreferences.getInstance();
                          // localStorage.setString('userData', result.toString());

                          // if (result == null) {
                          //   setState(() {
                          //     error = 'Invalid email/password!';
                          //   });
                          //   return;
                          // }

                          // Navigator.of(context).pushReplacement(
                          //     MaterialPageRoute(builder: (context) => Home()));
                          // }
                        }),
                  ),
                  ///////////////////// Social Authentication Options /////////////////////
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///////////////////////// dialog  ui start ///////////////////////////////
  _showDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: Colors.lime,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.black,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.black, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: Colors.lime[900],
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                          color: Colors.lime[900], fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.lime[900],
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(
                          color: Colors.lime[900], fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }
  ///////////////////////// dialog  ui end ///////////////////////////////

}
