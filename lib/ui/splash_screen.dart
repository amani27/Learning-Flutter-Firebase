import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learning_firebase/model/user.dart';
import 'package:learning_firebase/ui/login_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  Future<Timer> startTimer() async {
    return new Timer(Duration(seconds: 3), onDoneLoading);
  }

  onDoneLoading() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    // localStorage.clear();
    var user = localStorage.getString('userData');
    print(user);

    if (user == null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              // height: MediaQuery.of(context).size.height / 2,
              // padding: EdgeInsets.only(top: 15),
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width / 2.25,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.elliptical(100, 75),
                        topRight: Radius.elliptical(100, 75),
                      ),
                    ),
                    child: Text(' '),
                  ),
                  Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width / 2.25,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.elliptical(100, 75),
                        bottomRight: Radius.elliptical(100, 75),
                      ),
                    ),
                    child: Text(' '),
                  ),
                ],
              ),
            ),
            Container(
              height: 150,
              width: MediaQuery.of(context).size.width / 2.25,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.elliptical(100, 75),
                  bottomRight: Radius.elliptical(100, 75),
                ),
              ),
              child: Text(' '),
            ),
          ],
        ),
      ),
    );
  }
}
