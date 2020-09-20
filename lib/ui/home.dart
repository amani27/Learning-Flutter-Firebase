import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learning_firebase/model/user.dart';
import 'package:learning_firebase/service/auth_service.dart';
import 'package:learning_firebase/ui/chat_page.dart';
import 'package:learning_firebase/ui/login_page.dart';
import 'package:learning_firebase/ui/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  var localUser;

  ////////////// get user data mehtod start //////////////////
  _getUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    // localStorage.clear();
    var res = localStorage.getString('userData');
    print('$res --- res');
    var body = json.decode(res);
    print('body ----- $body');
    localUser = User.fromJson(body);
    print('localUser id ----- ${localUser.id}');
  }
  ////////////// get user data method end //////////////////

  //
  @override
  void initState() {
    _getUserData();
    super.initState();
  }
  //

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
          title: Text('HOME'),
          actions: <Widget>[
            PopupMenuButton<Choice>(
              onSelected: _onChoiceSelected,
              itemBuilder: (BuildContext context) {
                return [
                  Choice(title: 'Settings', icon: Icons.settings),
                  Choice(title: 'Log Out', icon: Icons.exit_to_app),
                ].map((Choice choice) {
                  return PopupMenuItem<Choice>(
                      value: choice,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            choice.icon,
                            color: Colors.lime[900],
                          ),
                          Container(
                            width: 10.0,
                          ),
                          Text(
                            choice.title,
                            style: TextStyle(color: Colors.lime[900]),
                          ),
                        ],
                      ));
                }).toList();
              },
            ),
          ],
          //  <Widget>[
          //   IconButton(
          //     icon: Icon(Icons.exit_to_app),
          //     onPressed: () async {
          //       await _auth.signOut();

          //       SharedPreferences localStorage =
          //           await SharedPreferences.getInstance();
          //       localStorage.clear();
          //       Navigator.of(context).pushReplacement(
          //           MaterialPageRoute(builder: (context) => LoginPage()));
          //     },
          //   ),
          // ],
        ),
        body: Container(
          //  StreamBuilder helps automatically manage the streams state and disposal of the stream when it's no longer used within your app
          child: StreamBuilder(
            stream: Firestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.lime[800]),
                  ),
                );
              } else {
                return snapshot.data.documents.length == 1
                    ? Center(
                        child: Text('No users to show!'),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            buildItem(context, snapshot.data.documents[index]),
                        itemCount: snapshot.data.documents.length,
                      );
              }
            },
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

  //////////////////// Users List Item container start //////////////////////
  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document.data['id'] == localUser.id) {
      return Container();
    } else {
      return Container(
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
        child: FlatButton(
          onPressed: () {
            print('onPressed onPressed ------------------------ hi');
            print(
                'peerId: ${document.data['id']}, peerAvatar: ${document.data['photoUrl']}');
            print('onPressed onPressed ------------------------ bye');

            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatPage(document.data['id'],
                    document.data['photoUrl'], document.data['nickname'])));
            // .push(MaterialPageRoute(builder: (context) => ChatPage(peerId: document.data['id'], peerAvatar: document.data['photoUrl'],)));
          },
          color: Colors.blueGrey[100],
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: <Widget>[
              Material(
                child: document.data['photoUrl'] != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.lime[800]),
                          ),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: document.data['photoUrl'],
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: Colors.grey,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Text(
                    // 'Nickname: ${document.data['nickname']}',
                    document.data['nickname'] == null
                        ? ''
                        : '${document.data['nickname']}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  //////////////////// Users List Item container end //////////////////////

  /////////////////// onChoiceSelected method start /////////////////////
  Future<void> _onChoiceSelected(Choice choice) async {
    if (choice.title == 'Log Out') {
      await _auth.signOut();

      SharedPreferences localStorage = await SharedPreferences.getInstance();

      localStorage.clear();

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SettingsPage()));
    }
  }
  /////////////////// onChoiceSelected method end /////////////////////

}

////////////// Choice class for pop up  menu start /////////////////
class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}
////////////// Choice class for pop up  menu end /////////////////
