import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_firebase/model/user.dart';
import 'package:learning_firebase/service/auth_service.dart';
import 'package:learning_firebase/ui/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool _loading = false;
  bool _googleLoading = false;
  bool _facebookLoading = false;

  // text field state
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('REGISTER'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0),

                ////////////////////////// input fields UI start ////////////////////////////
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
                  validator: (val) =>
                      val.length < 6 ? 'Enter a password 6+ chars long' : null,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                ),
                ////////////////////////// input fields UI end ////////////////////////////

                SizedBox(height: 20.0),

                ///////////////////////// sign up button start ///////////////////////////
                RaisedButton(
                    color: Colors.lime[800],
                    child: _loading
                        ? CircularProgressIndicator()
                        : Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white),
                          ),
                    onPressed: _loading
                        ? null
                        : () async {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                _loading = true;
                              });
                              User result =
                                  await _auth.registerWithEmailAndPassword(
                                      email, password);

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
                ///////////////////////// sign up button end ///////////////////////////
                SizedBox(height: 12.0),

                ///////////////////// sign up error text start ////////////////////////
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                ),
                ///////////////////// sign up error text end ////////////////////////

                SizedBox(height: 12.0),

                // ///////////////////// Social Authentication Options /////////////////////
                // Container(
                //   width: 200,
                //   child: RaisedButton(
                //       color: Colors.lime[800],
                //       child: _googleLoading
                //           ? CircularProgressIndicator()
                //           : Text(
                //               'Sign up with Google',
                //               style: TextStyle(color: Colors.white),
                //             ),
                //       onPressed: _googleLoading
                //           ? null
                //           : () async {
                //               setState(() {
                //                 _googleLoading = true;
                //               });
                //               print('Google Sign Up tapped');
                //               User user = await _auth.signInWithGoogle();

                //               if (user == null) {
                //                 setState(() {
                //                   error = 'Invalid email/password!';
                //                   print('null returned');
                //                   _googleLoading = false;
                //                 });
                //                 Fluttertoast.showToast(
                //                     msg: 'Something went wrong!');
                //                 return;
                //               }

                //               SharedPreferences localStorage =
                //                   await SharedPreferences.getInstance();
                //               localStorage.setString(
                //                   'userData', json.encode(user));

                //               Navigator.push(
                //                   context,
                //                   MaterialPageRoute(
                //                       builder: (context) => Home()));
                //             }),
                // ),

                // Container(
                //   width: 200,
                //   child: RaisedButton(
                //       color: Colors.lime[800],
                //       child: _facebookLoading
                //           ? CircularProgressIndicator()
                //           : Text(
                //               'Sign up with Facebook',
                //               style: TextStyle(color: Colors.white),
                //             ),
                //       onPressed: _facebookLoading
                //           ? null
                //           : () async {
                //               setState(() {
                //                 _facebookLoading = true;
                //               });
                //               // if (_formKey.currentState.validate()) {
                //               print('Facebook Sign Up tapped');
                //               User user = await _auth.signInWithFacebook();

                //               if (user == null) {
                //                 setState(() {
                //                   error = 'Invalid email/password!';
                //                   print('null returned');
                //                   _facebookLoading = false;
                //                 });
                //                 Fluttertoast.showToast(
                //                     msg: 'Something went wrong!');
                //                 return;
                //               }

                //               SharedPreferences localStorage =
                //                   await SharedPreferences.getInstance();
                //               localStorage.setString(
                //                   'userData', json.encode(user));

                //               Navigator.push(
                //                   context,
                //                   MaterialPageRoute(
                //                       builder: (context) => Home()));
                //             }),
                // ),
                // ///////////////////// Social Authentication Options /////////////////////
              ],
            ),
          ),
        ),
      ),
    );
  }
}
