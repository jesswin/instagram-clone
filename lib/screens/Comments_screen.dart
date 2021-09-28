import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Comments extends StatefulWidget {
  var docId;
  Comments(this.docId);
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final cmntcontoller = TextEditingController();

  var userName;
  var dpUrl;
  var creatorId;
  var isLoading = false;
  var uid = FirebaseAuth.instance.currentUser.uid;
  var docc;
  postComment() async {
    var cmnt = cmntcontoller.text;
    docc = widget.docId;
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance.collection("Posts/$docc/Comments").add({
      'comment': cmnt,
      'userName': userName,
      'commentedAt': Timestamp.now(),
      'dpUrl': dpUrl
    });
    FirebaseFirestore.instance
        .collection("Users")
        .doc(creatorId)
        .collection("Notifications")
        .add({
      'userName': userName,
      'message': "commented \"$cmnt\" on your photo",
      'dpUrl': dpUrl,
      'notificationTime': Timestamp.now()
    });
    setState(() {
      isLoading = false;
    });
  }

  getData() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .get()
        .then((val) {
      userName = val.data()['userName'];
      dpUrl = val.data()['dpUrl'];
    });
    await FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.docId)
        .get()
        .then((val) {
      creatorId = val.data()['userId'];
    });

    return [userName, creatorId];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
      ),
      backgroundColor: Color(0xFF000000),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: FutureBuilder(
                future: getData(),
                builder: (context, snap) {
                  return !snap.hasData
                      ? SpinKitRipple(
                          color: Colors.grey,
                        )
                      : StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Posts")
                              .doc(widget.docId)
                              .collection("Comments")
                              .orderBy('commentedAt')
                              .snapshots(),
                          builder: (context, snapShot) => ListView.builder(
                            itemBuilder: (context, index) {
                              print(snapShot.data.docs.length);
                              return !snapShot.hasData
                                  ? SpinKitRipple(
                                      color: Colors.grey,
                                    )
                                  : Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01,
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01),
                                            child: CircleAvatar(
                                                backgroundImage: snapShot.data
                                                                .docs[index]
                                                            ['dpUrl'] !=
                                                        null
                                                    ? snapShot.data.docs[index]
                                                                ['dpUrl'] !=
                                                            ""
                                                        ? CachedNetworkImageProvider(
                                                            snapShot.data
                                                                    .docs[index]
                                                                ['dpUrl'])
                                                        : AssetImage(
                                                            'lib/images/phperson.png')
                                                    : AssetImage(
                                                        'lib/images/phperson.png')),
                                          ),
                                          Text(
                                              '${snapShot.data.docs[index]['userName']} ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700)),
                                          Flexible(
                                            child: Text(
                                              snapShot.data.docs[index]
                                                  ['comment'],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                            },
                            itemCount: snapShot.data == null
                                ? 0
                                : snapShot.data.documents.length,
                          ),
                        );
                }),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                      hintText: "Add a Comment ",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 18)),
                  controller: cmntcontoller,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                    if (cmntcontoller.text != "") {
                      print("from key");
                      postComment();
                    }

                    setState(() {
                      cmntcontoller.clear();
                    });
                  },
                ),
              ),
              FlatButton(
                onPressed: () {
                  if (cmntcontoller.text != "") {
                    postComment();
                    FocusScope.of(context).unfocus();
                    setState(() {
                      cmntcontoller.clear();
                    });
                  }
                },
                child: Text(
                  "Post",
                  style: TextStyle(color: Colors.blue, fontSize: 18),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
