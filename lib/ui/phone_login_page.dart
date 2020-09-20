import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'otp_verify_page.dart';

class PhoneLoginPage extends StatefulWidget {
  @override
  _PhoneLoginPageState createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  TextEditingController controllerPhone = TextEditingController();
  FocusNode focusNodePhone;
  bool _phoneLoading = false;
  // final AuthService _auth = AuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LOGIN WITH PHONE NUMBER'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),

              ////////////////////// input field start ////////////////////////
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Phone Number',
                ),
              ),
              Container(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                    contentPadding: EdgeInsets.all(5.0),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  controller: controllerPhone,
                  focusNode: focusNodePhone,
                ),
                // margin: EdgeInsets.only(left: 25.0, right: 25.0),
              ),
              ////////////////////// input field end ////////////////////////

              SizedBox(height: 35),

              ///////////////////// Phone Authentication Option Start ////////////////////
              Container(
                width: 100,
                child: RaisedButton(
                    color: Colors.lime[800],
                    child: _phoneLoading
                        ? CircularProgressIndicator()
                        : Text(
                            'Send OTP',
                            style: TextStyle(color: Colors.white),
                          ),
                    onPressed: _phoneLoading
                        ? null
                        : () async {
                            // // hold the instance of the authenticated user
                            // FirebaseUser user;

                            setState(() {
                              _phoneLoading = true;
                            });

                            await _auth.verifyPhoneNumber(
                              timeout: Duration(seconds: 60),
                              // phoneNumber: '+880 1785-671700',
                              phoneNumber: controllerPhone.text,
                              verificationCompleted:
                                  (AuthCredential phoneAuthCredential) async {
                                print('verified');
                                // // ANDROID ONLY!

                                // // Sign the user in (or link) with the auto-generated credential
                                // await _auth
                                //     .signInWithCredential(phoneAuthCredential);

                                // user = (await _auth.signInWithCredential(
                                //         phoneAuthCredential))
                                //     .user;
                                // // Once signed in, return the UserCredential
                                // return _userFromFirebaseUser(user);
                              },
                              verificationFailed: (AuthException e) {
                                if (e.code == 'invalid-phone-number') {
                                  print(
                                      'The provided phone number is not valid.');
                                }
                                // user = null;
                                // Handle other errors
                              },
                              codeSent: (String verificationId,
                                  [int resendToken]) async {
                                print(
                                    'codeSent ---- verificationId ------- $verificationId');
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OtpVerifyPage(
                                              verificationId,
                                            )));

                                // Update the UI - wait for the user to enter the SMS code
                                // String smsCode = '654321';
                                // String smsCode = otp;

                                // // Create a PhoneAuthCredential with the code
                                // AuthCredential phoneAuthCredential =
                                //     PhoneAuthProvider.getCredential(
                                //         smsCode: smsCode,
                                //         verificationId: verificationId);

                                // // Sign the user in (or link) with the credential
                                // await _auth
                                //     .signInWithCredential(phoneAuthCredential);

                                // user = (await _auth.signInWithCredential(
                                //         phoneAuthCredential))
                                //     .user;
                                // // Once signed in, return the UserCredentialF
                                // return _userFromFirebaseUser(user);
                              },
                              codeAutoRetrievalTimeout:
                                  (String verificationId) {
                                // Auto-resolution timed out...
                                verificationId = verificationId;
                                print(verificationId);
                                print("Timeout");
                              },
                            );

                            setState(() {
                              _phoneLoading = false;
                            });

                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             OtpVerifyPage(controllerPhone.text)));

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
              ///////////////////// Phone Authentication Option Start ////////////////////
            ],
          ),
        ),
      ),
    );
  }
}
