import 'package:flutter/material.dart';
import 'package:learning_firebase/service/auth_service.dart';
import 'package:learning_firebase/ui/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HOME'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut();

              SharedPreferences localStorage =
                  await SharedPreferences.getInstance();
              localStorage.clear();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
      body: Container(
        child: Column(),
      ),
    );
  }
}
