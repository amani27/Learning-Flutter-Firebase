import 'package:flutter/material.dart';
import 'package:learning_firebase/model/user.dart';
import 'package:learning_firebase/ui/home.dart';
import 'package:learning_firebase/ui/login_page.dart';
import 'package:learning_firebase/ui/my_home_page.dart';
import 'package:learning_firebase/ui/splash_screen.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print(user);

    // return either the Home or LoginPage
    if (user == null) {
      return LoginPage();
    } else {
      return Home();
    }
  }
}
