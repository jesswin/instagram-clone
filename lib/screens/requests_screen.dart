import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Requests extends StatefulWidget {
  var pendingRequests = [];
  Requests(this.pendingRequests);
  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  var dpUrl = [];
  var userName = [];
  var displayName = [];
  var currentUser = FirebaseAuth.instance.currentUser.uid;
  var req;
  var currentFollowers = [];
  var userFollowingList = [];
  bool isLoading = false;

  deletePendingRequest(uid) async {
    print(widget.pendingRequests);
    if (widget.pendingRequests.contains(uid)) {
      widget.pendingRequests.remove(uid);
    }
    print(widget.pendingRequests);
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser)
        .update({
      'pendingRequests': widget.pendingRequests,
    });
    setState(() {});
  }

  confirmPendingRequest(uid) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser)
        .get()
        .then((val) {
      currentFollowers = val.data()['followersList'];
    });
    currentFollowers.add(uid);
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser)
        .update({'followersList': currentFollowers});
    setState(() {});
  }

  updateUserFollowing(uid) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .get()
        .then((val) {
      userFollowingList = val.data()['followingList'];
    });
    userFollowingList.add(currentUser);
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .update({'followingList': userFollowingList});
    setState(() {});
  }

  fetchdata() async {
    setState(() {
      isLoading = true;
    });
    for (var i in widget.pendingRequests) {
      await getUserInfo(i);
    }
    setState(() {
      isLoading = false;
    });
  }

  getUserInfo(uid) async {
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .get()
          .then((val) {
        dpUrl.add(val.data()['dpUrl']);
        userName.add(val.data()['userName']);
        displayName.add(val.data()['displayName']);
      });
    } catch (err) {
      print(err);
    }
    print(userName);
    return [dpUrl, userName, displayName];
  }

  @override
  void initState() {
    super.initState();
    widget.pendingRequests = widget.pendingRequests.reversed.toList();
    fetchdata();
  }

  Widget build(BuildContext context) {
    print(widget.pendingRequests);
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text(
            "Follow Requests",
            style: TextStyle(fontSize: 22),
          ),
        ),
        body: isLoading
            ? SpinKitRipple(
                color: Colors.grey,
              )
            : widget.pendingRequests.length == 0
                ? Center(
                    child: Text(
                      "There are no Pending Requests!",
                      style: TextStyle(
                          color: Theme.of(context).accentColor, fontSize: 20),
                    ),
                  )
                : ListView.builder(
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: dpUrl[index] != null
                                ? dpUrl[index] != ""
                                    ? dpUrl[index]
                                    : AssetImage('lib/images/phperson.png')
                                : AssetImage('lib/images/phperson.png')),
                        title: Text(
                          userName[index],
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        subtitle: Text(
                          displayName[index],
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 18),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(4)),
                              margin: EdgeInsets.only(right: 7),
                              height: 40,
                              child: RaisedButton(
                                color: Colors.blue,
                                child: Text(
                                  "Confirm",
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 16),
                                ),
                                onPressed: () {
                                  req = widget.pendingRequests[index];
                                  deletePendingRequest(
                                      widget.pendingRequests[index]);
                                  confirmPendingRequest(req);
                                  updateUserFollowing(req);
                                },
                              ),
                            ),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(4)),
                              child: RaisedButton(
                                color: Colors.black,
                                child: Text(
                                  "Delete",
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 16),
                                ),
                                onPressed: () {
                                  deletePendingRequest(
                                      widget.pendingRequests[index]);
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    itemCount: widget.pendingRequests.length,
                  ));
  }
}
