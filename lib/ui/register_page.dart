import 'package:flutter/material.dart';
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
                SizedBox(height: 20.0),
                RaisedButton(
                    color: Colors.lime[800],
                    child: _loading
                        ? CircularProgressIndicator()
                        : Text(
                            'Register',
                            style: TextStyle(color: Colors.white),
                          ),
                    onPressed: _loading
                        ? null
                        : () async {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                _loading = true;
                              });
                              dynamic result =
                                  await _auth.registerWithEmailAndPassword(
                                      email, password);

                              SharedPreferences localStorage =
                                  await SharedPreferences.getInstance();
                              localStorage.setString(
                                  'userData', result.toString());

                              if (result == null) {
                                setState(() {
                                  error = 'Invalid email/password!';
                                  _loading = false;
                                });
                                return;
                              }

                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => Home()));
                            }
                          }),
                SizedBox(height: 12.0),
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
