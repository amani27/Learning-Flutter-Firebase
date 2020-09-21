import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learning_firebase/model/user.dart';
import 'package:learning_firebase/service/auth_service.dart';
import 'package:learning_firebase/ui/home.dart';
import 'package:learning_firebase/ui/phone_login_page.dart';
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
  bool _facebookLoading = false;
  bool _phoneLoading = false;

  String error = '';

  TextEditingController phoneController = TextEditingController();

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
                                  User result =
                                      await _auth.signInWithEmailAndPassword(
                                          email, password);
                                  print(result);

                                  if (result == null) {
                                    setState(() {
                                      error = 'Invalid email/password!';
                                      _loading = false;
                                    });
                                    Fluttertoast.showToast(msg: error);
                                    return;
                                  }

                                  // SharedPreferences localStorage =
                                  //     await SharedPreferences.getInstance();
                                  // localStorage.setString(
                                  //     'userData', json.encode(result));

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
                                    print('null returned');
                                    _googleLoading = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: 'Something went wrong!');
                                  return;
                                }

                                // SharedPreferences localStorage =
                                //     await SharedPreferences.getInstance();
                                // localStorage.setString(
                                //     'userData', json.encode(user));

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Home()));
                              }),
                  ),

                  Container(
                    width: 200,
                    child: RaisedButton(
                        color: Colors.lime[800],
                        child: _facebookLoading
                            ? CircularProgressIndicator()
                            : Text(
                                'Sign in with Facebook',
                                style: TextStyle(color: Colors.white),
                              ),
                        onPressed: _facebookLoading
                            ? null
                            : () async {
                                setState(() {
                                  _facebookLoading = true;
                                });
                                // if (_formKey.currentState.validate()) {
                                print('Facebook Sign In tapped');
                                User user = await _auth.signInWithFacebook();

                                if (user == null) {
                                  setState(() {
                                    error = 'Invalid email/password!';
                                    print('null returned');
                                    _facebookLoading = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: 'Something went wrong!');
                                  return;
                                }

                                // SharedPreferences localStorage =
                                //     await SharedPreferences.getInstance();
                                // localStorage.setString(
                                //     'userData', json.encode(user));

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Home()));
                              }),
                  ),
                  ///////////////////// Social Authentication Options /////////////////////

                  ///////////////////// Phone Authentication Option Start ////////////////////
                  Container(
                    width: 200,
                    child: RaisedButton(
                        color: Colors.lime[800],
                        child: _phoneLoading
                            ? CircularProgressIndicator()
                            : Text(
                                'Sign in with Phone',
                                style: TextStyle(color: Colors.white),
                              ),
                        onPressed: _phoneLoading
                            ? null
                            : () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PhoneLoginPage()));
                                // _showModalBottomSheet(context);
                                //   setState(() {
                                //     _phoneLoading = true;
                                //   });

                                //   print('Phone Sign In tapped');
                                //   User user = await _auth.signInWithPhone();

                                //   if (user == null) {
                                //     setState(() {
                                //       print('null returned');
                                //       _phoneLoading = false;
                                //     });
                                //     Fluttertoast.showToast(
                                //         msg: 'Something went wrong!');
                                //     return;
                                //   }

                                //   Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //           builder: (context) => Home()));
                              }),
                  ),
                  ///////////////////// Phone Authenticatio Option Start ////////////////////
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

  ////////////////////// modal bottom sheet ui start //////////////////////////
  _showModalBottomSheet(BuildContext ctx) {
    phoneController.text = '';

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: ctx,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 5,
            left: 5,
            right: 5,
          ),
          margin: EdgeInsets.all(5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 25, left: 10, right: 10),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    focusedBorder: OutlineInputBorder(
                      // borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      // borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      // borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  controller: phoneController,
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.all(15),
                child: RaisedButton(
                  child: Text(
                    'ADD',
                  ),
                  onPressed: () async {
                    //   setState(() {
                    //     _phoneLoading = true;
                    //   });

                    //   print('Phone Sign In tapped');
                    //   User user = await _auth.signInWithPhone();

                    //   if (user == null) {
                    //     setState(() {
                    //       print('null returned');
                    //       _phoneLoading = false;
                    //     });
                    //     Fluttertoast.showToast(msg: 'Something went wrong!');
                    //     return;
                    //   }

                    //   Navigator.push(context,
                    //       MaterialPageRoute(builder: (context) => Home()));
                  },
                  textColor: Colors.white,
                  color: Theme.of(context).primaryColor,
                ),
              )
            ],
          ),
        );
      },
    );
  }
  ////////////////////// modal bottom sheet ui end //////////////////////////

}
