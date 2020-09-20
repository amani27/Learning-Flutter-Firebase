import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:learning_firebase/model/user.dart';
import 'package:learning_firebase/ui/home.dart';
import 'package:learning_firebase/ui/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerName;

  ChatPage(this.peerId, this.peerAvatar, this.peerName);
  // ChatPage({@required this.peerId, @required this.peerAvatar});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController textEditingController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  bool isLoading = false;
  bool _isShowSticker = false;
  File avatarImageFile;

  var localUser;
  var groupChatId = '';
  List<DocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  final int _limitIncrement = 20;

  File image;
  String imageUrl = '';

  /////////////////// pick image method start /////////////////////
  _pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    image = File(pickedFile.path);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    _uploadImage();
  }
  /////////////////// pick image method end //////////////////////

  ///
  //////////////////////// _uploadImage method start //////////////////////
  _uploadImage() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    // Cloud Storage is designed to help quickly and easily store and serve user-generated content, such as photos and videos.
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(image);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        _onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }
  //////////////////////// _uploadImage method end ///////////////////////

  //////////////////////// _onSendMessage method start ///////////////////////
  void _onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      // // Create a reference to the document the transaction will use
      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      // Transactions are a way to ensure that a write operation only occurs using the latest data available on the server
      Firestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': localUser.id,
            'idTo': widget.peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Colors.black,
          textColor: Colors.red);
    }
  }
  /////////////////////// _onSendMessage method end ///////////////////////

  ///
  _onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        _isShowSticker = false;
      });
    }
  }

  ///

  ////////////// get user data mehtod start //////////////////
  _getUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var res = localStorage.getString('userData');
    print('$res --- res');
    var body = json.decode(res);
    print('body ----- $body');
    localUser = User.fromJson(body);
    print('localUser id ----- ${localUser.id}');

    if (localUser.id.hashCode <= widget.peerId.hashCode) {
      setState(() {
        groupChatId = '${localUser.id}-${widget.peerId}';
      });
    } else {
      setState(() {
        groupChatId = '${widget.peerId}-${localUser.id}';
      });
    }

    print('$groupChatId ---- groupChatId');

    Firestore.instance
        .collection('users')
        .document(localUser.id)
        .updateData({'chattingWith': widget.peerId});
  }
  ////////////// get user data method end //////////////////

  /////////////////////_onBackPressed method start /////////////////////
  _onBackPressed() {
    if (_isShowSticker) {
      setState(() {
        _isShowSticker = false;
      });
    } else {
      Firestore.instance
          .collection('users')
          .document(localUser.id)
          .updateData({'chattingWith': null});
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
    }
  }
  /////////////////////_onBackPressed method end /////////////////////

  ///
  @override
  void initState() {
    // groupChatId == '';

    focusNode.addListener(_onFocusChange);

    _getUserData();

    super.initState();
  }

  ///

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _onBackPressed();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.peerName == null ? 'CHAT' : widget.peerName,
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              _onBackPressed();
            },
            icon: Icon(
              Icons.arrow_back,
            ),
          ),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              _buildMessagesList(),
              _isShowSticker ? _buildStickerBox() : Container(),
              _msgInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  ////////////////////// msg input field ui start /////////////////////////
  _msgInputBar() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: _pickImage,
                color: Colors.lime[900],
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                onPressed: () {
                  setState(() {
                    // Hide keyboard when sticker appear
                    focusNode.unfocus();
                    _isShowSticker = !_isShowSticker;
                  });
                },
                color: Colors.lime[900],
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  _onSendMessage(textEditingController.text, 0);
                },
                style: TextStyle(color: Colors.lime[900], fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _onSendMessage(textEditingController.text, 0),
                color: Colors.lime[900],
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }
  ////////////////////// msg input field ui end /////////////////////////

  ///////////////////// sticker input box ui start ///////////////////////
  _buildStickerBox() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => _onSendMessage('mimi1', 2),
                // onPressed: () {},
                child: Image.asset(
                  'assets/images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => _onSendMessage('mimi2', 2),
                // onPressed: () {},
                child: Image.asset(
                  'assets/images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => _onSendMessage('mimi3', 2),
                // onPressed: () {},
                child: Image.asset(
                  'assets/images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => _onSendMessage('mimi4', 2),
                // onPressed: () {},
                child: Image.asset(
                  'assets/images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => _onSendMessage('mimi5', 2),
                // onPressed: () {},
                child: Image.asset(
                  'assets/images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => _onSendMessage('mimi6', 2),
                // onPressed: () {},
                child: Image.asset(
                  'assets/images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => _onSendMessage('mimi7', 2),
                // onPressed: () {},
                child: Image.asset(
                  'assets/images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => _onSendMessage('mimi8', 2),
                // onPressed: () {},
                child: Image.asset(
                  'assets/images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => _onSendMessage('mimi9', 2),
                // onPressed: () {},
                child: Image.asset(
                  'assets/images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }
  ///////////////////// sticker input box ui end ///////////////////////

  ////////////////////////// Messages List Item UI start //////////////////////////
  _buildMessagesListItem(int index, DocumentSnapshot document) {
    if (document.data['idFrom'] == localUser.id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document.data['type'] == 0
              // Text
              ? Container(
                  child: Text(
                    document.data['content'],
                    style: TextStyle(
                      color: Colors.black,
                      // color: Colors.lime[900],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : document.data['type'] == 1
                  // Image
                  ? Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.lime[800]),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'assets/images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document.data['content'],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => FullPhoto(
                          //             url: document.data['content'])));
                        },
                        padding: EdgeInsets.all(0),
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
                  // Sticker
                  : Container(
                      child: Image.asset(
                        'assets/images/${document.data['content']}.gif',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: widget.peerAvatar == null ||
                                widget.peerAvatar == ''
                            ? Icon(
                                Icons.account_circle,
                                size: 35.0,
                                color: Colors.grey,
                              )
                            : CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.lime[800]),
                                  ),
                                  width: 35.0,
                                  height: 35.0,
                                  padding: EdgeInsets.all(10.0),
                                ),
                                imageUrl: widget.peerAvatar,
                                //  == null
                                //     ? 'assets/images/img_not_available.jpeg'
                                //     : widget.peerAvatar,

                                width: 35.0,
                                height: 35.0,
                                fit: BoxFit.cover,
                              ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                document.data['type'] == 0
                    ? Container(
                        child: Text(
                          document.data['content'],
                          style: TextStyle(
                            // color: Colors.white,
                            color: Colors.black,
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Colors.lime[200],
                            // color: Colors.lime,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : document.data['type'] == 1
                        ? Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.lime[800]),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      'assets/images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document.data['content'],
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => FullPhoto(
                                //             url: document.data['content'])));
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : Container(
                            child: Image.asset(
                              'assets/images/${document.data['content']}.gif',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document.data['timestamp']))),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }
  ///////////////////////// Messages List Item UI end /////////////////////////////

  ///

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data['idFrom'] == localUser.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data['idFrom'] != localUser.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  ///

  ///////////////////////// Messages List UI start /////////////////////////////
  Widget _buildMessagesList() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lime[800])))
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.lime[800])));
                } else {
                  listMessage.addAll(snapshot.data.documents);
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => _buildMessagesListItem(
                        index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
  ///////////////////////// Messages List UI end /////////////////////////////

}
