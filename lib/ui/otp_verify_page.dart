import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_firebase/model/user.dart';
import 'package:learning_firebase/service/auth_service.dart';
import 'package:learning_firebase/ui/home.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerifyPage extends StatefulWidget {
  String
      // phoneNumber,
      verificationId;

  // OtpVerifyPage(this.phoneNumber, this.verificationId);
  OtpVerifyPage(this.verificationId);

  @override
  _OtpVerifyPageState createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  TextEditingController textEditingController = TextEditingController();
  String _currentText = '';
  bool _phoneLoading = false;
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VERIFY OTP'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              Container(
                child: PinCodeTextField(
                  length: 6,
                  obsecureText: true,
                  animationType: AnimationType.slide,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    inactiveColor: Colors.black,
                    selectedColor: Colors.lime[900],
                    fieldHeight: 50,
                    fieldWidth: 35,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  controller: textEditingController,
                  onCompleted: (v) {
                    print("Completed");
                    _handleCompletion();
                  },
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      _currentText = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 20.0),
              _phoneLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  /////////////////////// _handleCompletion() method start ///////////////////////
  _handleCompletion() async {
    setState(() {
      _phoneLoading = true;
    });

    print('Phone Sign In tapped');
    User user = await _auth.signInWithPhone(
        widget.verificationId, textEditingController.text);

    if (user == null) {
      setState(() {
        print('null returned');
        _phoneLoading = false;
      });
      Fluttertoast.showToast(msg: 'Something went wrong!');
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }
  /////////////////////// _handleCompletion() method end ////////////////////////
}
