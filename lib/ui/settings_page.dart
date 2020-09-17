import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learning_firebase/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController controllerNickname = TextEditingController();
  final FocusNode focusNodeNickname = FocusNode();

  var localUser;

  bool isLoading = false;
  File avatarImageFile;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  /////////////////// get local user data method start ////////////////////
  void _getUserData() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var res = localStorage.getString('userData');
    print('$res --- res');
    var body = json.decode(res);
    print('body ----- $body');
    localUser = User.fromJson(body);
    print('localUser id ----- ${localUser.id}');

    setState(() {
      isLoading = false;
      controllerNickname.text =
          localUser.nickname == null ? '' : localUser.nickname;
    });
  }
  /////////////////// get local user data method end ////////////////////

  /////////////////// pick image method start /////////////////////
  _pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    File image = File(pickedFile.path);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    _uploadImage();
  }
  /////////////////// pick image method end //////////////////////

  //////////////////////// _uploadImage method start //////////////////////
  _uploadImage() async {
    String fileName = localUser.id;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;

        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          var photoUrl = downloadUrl;

          Firestore.instance
              .collection('users')
              .document(localUser.id)
              .updateData({
            'nickname': localUser.nickname,
            'photoUrl': photoUrl
          }).then((data) {
            var updatedUser = {
              'id': localUser.id,
              'nickname': localUser.nickname,
              'photoUrl': photoUrl
            };

            localStorage.setString('userData', json.encode(updatedUser));

            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SettingsPage()));

            setState(() {
              isLoading = false;
            });

            Fluttertoast.showToast(msg: "Upload successful");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });

            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });

          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        setState(() {
          isLoading = false;
        });

        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }
  //////////////////////// _uploadImage method end ///////////////////////

  //////////////////////// _updateName method start ///////////////////////
  _updateName() async {
    setState(() {
      isLoading = true;
    });
    focusNodeNickname.unfocus();
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    Firestore.instance.collection('users').document(localUser.id).updateData({
      'nickname': controllerNickname.text,
      'photoUrl': localUser.photoUrl
    }).then((data) {
      var updatedUser = {
        'id': localUser.id,
        'nickname': controllerNickname.text,
        'photoUrl': localUser.photoUrl == null ? '' : localUser.photoUrl
      };

      localStorage.setString('userData', json.encode(updatedUser));
      setState(() {
        isLoading = true;
      });
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SettingsPage()));

      Fluttertoast.showToast(msg: "Update successful");
    });
  }
  //////////////////////// _updateName method end ///////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SETTINGS'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    ///////////////////// Image Avatar Container Start ////////////////////////
                    Container(
                      margin: EdgeInsets.only(
                        top: 30,
                        bottom: 10,
                      ),
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            (avatarImageFile == null)
                                ? (localUser.photoUrl != null ||
                                        localUser.photoUrl != ''
                                    ? Material(
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Container(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.lime[800]),
                                            ),
                                            width: 90.0,
                                            height: 90.0,
                                            padding: EdgeInsets.all(20.0),
                                          ),
                                          imageUrl: localUser.photoUrl,
                                          width: 90.0,
                                          height: 90.0,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(45.0)),
                                        clipBehavior: Clip.hardEdge,
                                      )
                                    : Icon(
                                        Icons.account_circle,
                                        size: 90.0,
                                        color: Colors.grey,
                                      ))
                                : Material(
                                    child: Image.file(
                                      avatarImageFile,
                                      width: 90.0,
                                      height: 90.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(45.0)),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                            IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.lime[900].withOpacity(0.6),
                              ),
                              onPressed: _pickImage,
                              padding: EdgeInsets.all(30.0),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.grey,
                              iconSize: 30.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    ///////////////////// Image Avatar Container End ////////////////////////

                    Column(
                      children: <Widget>[
                        ///////////////////// Input Field Start //////////////////////
                        Container(
                          child: Text(
                            'Name',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.lime[900],
                            ),
                          ),
                          margin: EdgeInsets.only(
                            left: 25,
                            top: 25,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        Container(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Enter your name',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            controller: controllerNickname,
                            focusNode: focusNodeNickname,
                          ),
                          margin: EdgeInsets.only(left: 25.0, right: 25.0),
                        ),
                        ///////////////////// Input Field End //////////////////////

                        /////////////////////////// Update Button Start ////////////////////////
                        Container(
                          child: FlatButton(
                            onPressed: _updateName,
                            child: Text(
                              'UPDATE',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            color: Colors.lime[800],
                            // highlightColor: Colors.red,
                            splashColor: Colors.transparent,
                            textColor: Colors.white,
                            padding:
                                EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                          ),
                          margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
                        ),
                        /////////////////////////// Update Button End ////////////////////////
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
