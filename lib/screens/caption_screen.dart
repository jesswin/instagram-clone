import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';

import 'package:iinstagram/widgets/tab.dart';

class CaptionScreen extends StatefulWidget {
  final String img;
  final String imgName;

  CaptionScreen(
    this.img,
    this.imgName,
  );

  @override
  _CaptionScreenState createState() => _CaptionScreenState();
}

class _CaptionScreenState extends State<CaptionScreen> {
  FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  var connectivityResult;
  final uid = FirebaseAuth.instance.currentUser.uid;
  bool isUploading = false;
  final caption = TextEditingController();

  DocumentReference docRef;
  showToast() {
    fToast.removeQueuedCustomToasts();
    fToast.showToast(
        child: Text(
          "Please Check Your Internet Connnection",
          style: TextStyle(color: Theme.of(context).accentColor, fontSize: 16),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 5));
  }

  checkConn() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      print("connn");
      return true;
    } else {
      print("connnnottt");
      showToast();
    }
  }

  screenHeight(context) {
    var height =
        MediaQuery.of(context).size.height - AppBar().preferredSize.height;
    height = height - 200;
    return height;
  }

  uploadImage() async {
    FocusScope.of(context).unfocus();
    if (await checkConn()) {
      try {
        setState(() {
          isUploading = true;
        });
        final ref = FirebaseStorage.instance
            .ref()
            .child(uid)
            .child(widget.imgName + Timestamp.now().toString());
        await ref.putFile(File(widget.img));
        final url = await ref.getDownloadURL();
        docRef = FirebaseFirestore.instance.collection("Posts").doc();
        docRef.set({
          'posturl': url,
          'caption': caption.text.trim(),
          'postedOn': Timestamp.now(),
          'userId': uid,
          'postId': docRef.id,
          'likedBy': []
        });
      } catch (e) {
        print(e.code);
      }

      try {
        var posts;
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(uid)
            .get()
            .then((val) {
          posts = val.data()['posts'];
          print(posts);
          posts += 1;
          print(posts);
        });
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(uid)
            .update({"posts": posts});
      } catch (err) {
        print(err);
      }
      setState(() {
        isUploading = false;
      });
      Navigator.of(context).pushReplacementNamed(
        Tabbarr.routeName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: isUploading
          ? () {
              return Future(() => false);
            }
          : null,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text(
            "New Post",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.check,
                  color: isUploading ? Colors.grey : Colors.blue,
                  size: 30,
                ),
                onPressed: isUploading ? null : () => uploadImage())
          ],
        ),
        body: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Image.file(
                    File(widget.img),
                    fit: BoxFit.cover,
                  ),
                  height: 100,
                  width: 100,
                ),
                Expanded(
                  child: TextFormField(
                      controller: caption,
                      autocorrect: true,
                      enableSuggestions: true,
                      maxLength: 150,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                      },
                      style: TextStyle(color: Theme.of(context).accentColor),
                      decoration: InputDecoration(
                          hintText: "Write a Caption",
                          hintStyle:
                              TextStyle(color: Theme.of(context).accentColor))),
                ),
              ],
            ),
            isUploading
                ? Column(children: [
                    SizedBox(
                      height: screenHeight(context),
                    ),
                    Row(children: [
                      Text(
                        "Finishing Up",
                        style: TextStyle(
                            color: Theme.of(context).accentColor, fontSize: 18),
                      ),
                      Icon(
                        Icons.check,
                        color: Colors.blue,
                        size: 25,
                      ),
                    ]),
                    LinearProgressIndicator(
                      backgroundColor: Colors.blue,
                    ),
                  ])
                : Container()
          ],
        ),
      ),
    );
  }
}
