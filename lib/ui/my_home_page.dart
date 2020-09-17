import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  var localItemsList;
  bool done = false;
  final titleController = TextEditingController();
  bool _isLoading = false;
  var itemData;
  String enteredTitle = '';

  // List items = [
  //   {'title': 'Task 1', 'date': DateTime.now(), 'done': false},
  //   {'title': 'Task 2', 'date': DateTime.now(), 'done': true},
  //   {'title': 'Task 3', 'date': DateTime.now(), 'done': false},
  //   {'title': 'Task 4', 'date': DateTime.now(), 'done': false},
  //   {'title': 'Task 5', 'date': DateTime.now(), 'done': true}
  // ];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: Duration(milliseconds: 2500), vsync: this);

    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    animationController.forward();

    return WillPopScope(
        onWillPop: _onWillPop,
        child: AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget child) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('Flutter + Firebase'),
                ),
                floatingActionButton: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      // Remove List Button
                      // if (items.length > 0)
                      FloatingActionButton(
                        onPressed: () {
                          showDeleteConfirmationDialog();
                        },
                        tooltip: 'Remove All Items',
                        child: Icon(Icons.delete),
                      ),

                      SizedBox(width: 15),

                      // Add to List Button
                      FloatingActionButton(
                        onPressed: () =>
                            _showAddNewItemModal(context, false, -1),
                        tooltip: 'Add New Item',
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child:
                      // _isLoading
                      //     ? Center(child: CircularProgressIndicator())
                      // : items.length == 0
                      //     ? Container(
                      //         alignment: Alignment.center,
                      //         child: Text('Nothing to do! :D'),
                      //       ) :
                      Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.only(bottom: 15, top: 10),
                          child: StreamBuilder(
                              stream: Firestore.instance
                                  .collection("MyTodos")
                                  .snapshots(),
                              builder: (context, snapshots) {
                                return ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshots.data.documents.length,
                                  // itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot documentSnapshot =
                                        snapshots.data.documents[index];
                                    return Transform(
                                      transform: Matrix4.translationValues(
                                          0.0, animation.value * height, 0.0),
                                      child: Card(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              /////////////////// done/undone checkbox start ////////////////
                                              Container(
                                                child: IconButton(
                                                  onPressed: () {
                                                    // items[index]
                                                    //         ['done'] =
                                                    //     !items[index]
                                                    //         ['done'];
                                                  },
                                                  icon:
                                                      // items[index]
                                                      //         ['done']
                                                      //     ? Icon(
                                                      //         Icons
                                                      //             .check_box,
                                                      //         color: Colors
                                                      //             .green) :
                                                      Icon(
                                                          Icons
                                                              .check_box_outline_blank,
                                                          color: Colors.red),
                                                ),
                                              ),
                                              /////////////////// done/undone checkbox start ////////////////

                                              /////////////////// list item details start //////////////////
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _showAddNewItemModal(
                                                        context, true, index);
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          documentSnapshot.data[
                                                              "todoTitle"],
                                                          // items[index]
                                                          //     [
                                                          //     'title'],
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .deepPurple,
                                                            fontSize: 15.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          // DateFormat(
                                                          //         'EEE, M/d/y')
                                                          //     .format(items[index]
                                                          //         [
                                                          //         'date']),
                                                          DateFormat(
                                                                  'EEE, M/d/y')
                                                              .format(DateTime
                                                                  .now()),
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              /////////////////// list item details start //////////////////

                                              ///////
                                              Container(
                                                child: IconButton(
                                                  onPressed: () {
                                                    DocumentReference
                                                        documentReference =
                                                        Firestore.instance
                                                            .collection(
                                                                "MyTodos")
                                                            .document(
                                                                documentSnapshot[
                                                                    "todoTitle"]);

                                                    documentReference
                                                        .delete()
                                                        .whenComplete(() {
                                                      print("deleted");
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                  ),
                                                ),
                                              ),
                                              ///////
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                        ),
                      ),
                      // SizedBox(height: 100)
                    ],
                  ),
                ),
              );
            }));
  }

  /////////////////// Add Data method start //////////////////////
  Future<void> submitData() async {
    enteredTitle = titleController.text;
    final enteredDate = DateTime.now();

    if (enteredTitle.isEmpty) {
      return;
    }

    DocumentReference documentReference =
        Firestore.instance.collection("MyTodos").document(enteredTitle);

    Map<String, String> todos = {"todoTitle": enteredTitle};

    documentReference.setData(todos).whenComplete(() {
      print("$enteredTitle created");
    });

    Navigator.of(context).pop();
  }
  /////////////////// Add Data method end //////////////////////

  /////////////////// editData method start //////////////////////
  Future<void> editData(int index, bool eneteredDone) async {
    final enteredTitle = titleController.text;
    final enteredDate = DateTime.now();

    if (enteredTitle.isEmpty) {
      return;
    }

    Navigator.of(context).pop();
  }
  /////////////////// editData method end //////////////////////

  ////////////////////// modal bottom sheet to add / edit items start ////////////////
  void _showAddNewItemModal(BuildContext ctx, bool isFromEdit, int index) {
    titleController.text = '';

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      context: ctx,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 5,
            left: 5,
            right: 5,
          ),
          margin: EdgeInsets.all(5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 25, left: 10, right: 10),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Task',
                    labelStyle: TextStyle(),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  controller: titleController,
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.all(15),
                child: RaisedButton(
                  child: Text(
                    // isFromEdit ? 'EDIT' :
                    'ADD',
                  ),
                  onPressed: () {
                    submitData();
                  },
                  textColor: Colors.white,
                  color: Theme.of(context).primaryColor,
                ),
              )
            ],
          ),
        );
      },
    );
  }
  ////////////////////// modal bottom sheet to add / edit items end //////////////////

  //////////////////// confirm delete dialog start //////////////////////
  Future<void> showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        content: new Text(
            'Are you sure you want to delete all items in the to-do list?'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(
              'No',
              style: TextStyle(color: Colors.purple),
            ),
          ),
          new FlatButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
            },
            child: new Text(
              'Yes',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }
  //////////////////// confirm delete dialog end ////////////////////////

  ///////////////////
  //
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            content: new Text('Are you sure you want to exit this app?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  'No',
                  style: TextStyle(color: Colors.purple),
                ),
              ),
              new FlatButton(
                onPressed: () => exit(0),
                child: new Text(
                  'Yes',
                  style: TextStyle(color: Colors.purple),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }
  //////////////////
}
