import 'package:flutter/material.dart';
import 'package:learning_firebase/model/user.dart';
import 'package:learning_firebase/service/auth_service.dart';
import 'package:learning_firebase/ui/login_page.dart';
import 'package:learning_firebase/ui/my_home_page.dart';
import 'package:learning_firebase/ui/splash_screen.dart';
import 'package:learning_firebase/ui/wrapper.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
        // StreamProvider<User>.value( // with provider pkg
        //   value: AuthService().user, // with provider pkg
        //   child: // with provider pkg
        MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lime,
      ),
      // home: Wrapper(), // with provider pkg
      home: SplashScreen(),
      // ),
    );
  }
}
