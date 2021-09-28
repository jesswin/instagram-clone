import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:iinstagram/screens/requests_screen.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  var pendingRequests = [];
  var dpUrl;
  var currentUser = FirebaseAuth.instance.currentUser.uid;
  getPendingRequest() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser)
        .get()
        .then((val) {
      pendingRequests = val.data()['pendingRequests'];
    });

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(pendingRequests[pendingRequests.length - 1])
        .get()
        .then((val) {
      dpUrl = val.data()['dpUrl'];
    });
    print(pendingRequests);
    return (pendingRequests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          "Activity",
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: getPendingRequest(),
              builder: (context, snap) {
                return pendingRequests.length == 0
                    ? Container()
                    : GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) =>
                                      Requests(pendingRequests)))
                              .then((_) {
                            setState(() {});
                          });
                        },
                        child: ListTile(
                          leading: Stack(children: [
                            CircleAvatar(
                                radius: 35,
                                backgroundImage: dpUrl != null
                                    ? dpUrl != ""
                                        ? dpUrl
                                        : AssetImage('lib/images/phperson.png')
                                    : AssetImage('lib/images/phperson.png')),
                            Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.red,
                                  ),
                                  height: 30,
                                  width: 30,
                                  child: Center(
                                    child: Text(
                                      pendingRequests.length > 0
                                          ? pendingRequests.length.toString()
                                          : "0",
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                          fontSize: 17),
                                    ),
                                  ),
                                ))
                          ]),
                          title: Text(
                            "Follow Requests",
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).accentColor),
                          ),
                          subtitle: Text(
                            "Approve or Ignore Requests",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      );
              }),
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Users")
                    .doc(currentUser)
                    .collection("Notifications")
                    .orderBy('notificationTime', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  return !snapshot.hasData || snapshot.data?.documents.isEmpty
                      ? Center(
                          child: Text("There are no new Notifications",
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 22,
                              )),
                        )
                      : ListView.builder(
                          itemCount: snapshot.data == null
                              ? 0
                              : snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                                contentPadding:
                                    EdgeInsets.only(top: 10, left: 14),
                                leading: CircleAvatar(
                                  radius: 35,
                                  backgroundImage: snapshot.data.docs[index]
                                              ['dpUrl'] !=
                                          null
                                      ? snapshot.data.docs[index]['dpUrl'] != ""
                                          ? CachedNetworkImageProvider(snapshot
                                              .data.docs[index]['dpUrl'])
                                          : AssetImage(
                                              'lib/images/phperson.png')
                                      : AssetImage('lib/images/phperson.png'),
                                ),
                                title: RichText(
                                  text: TextSpan(
                                    text:
                                        '${snapshot.data.docs[index]['userName']} ',
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              '${snapshot.data.docs[index]['message']} ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color:
                                                Theme.of(context).accentColor,
                                            fontSize: 18,
                                          )),
                                    ],
                                  ),
                                ));
                          },
                        );
                }),
          )
        ],
      ),
    );
  }
}
