import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:iinstagram/screens/add_post_screen.dart';
import 'package:iinstagram/widgets/showData.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var userName = "";
  var displayName = "";
  var dpUrl = "";
  var posts = 0;
  var followersList = [];
  var followingList = [];
  var uid = FirebaseAuth.instance.currentUser.uid;
  bool enlarge = false;
  var img;
  Future<void> getData() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .get()
        .then((snap) => {
              userName = snap.data()['userName'],
              displayName = snap.data()['displayName'],
              dpUrl = snap.data()['dpUrl'],
              posts = snap.data()['posts'],
              followersList = snap.data()['followersList'],
              followingList = snap.data()['followingList'],
            });
    setState(() {});
    return [userName, displayName, dpUrl, posts, followersList, followingList];
  }

  showModalSheet(context) {
    showModalBottomSheet(
        backgroundColor: Colors.grey.withOpacity(0.1),
        context: context,
        builder: (BuildContext context) {
          return Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.15),
            child: Column(children: [
              Divider(
                color: Colors.white,
                endIndent: MediaQuery.of(context).size.width * 0.45,
                indent: MediaQuery.of(context).size.width * 0.45,
                thickness: 2.5,
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AddPost())),
                child: ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: Theme.of(context).accentColor,
                  ),
                  title: Text(
                    "Create Post for Feed",
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
              ),
            ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: userName != ""
              ? Text(
                  userName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                )
              : Text(
                  "Instagram",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
          actions: [
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () => showModalSheet(context)),
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
              ),
              onSelected: (_) {
                FirebaseAuth.instance.signOut();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "LogOut",
                  child: ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Colors.black,
                    ),
                    title: Text(
                      "Logout",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
        body: FutureBuilder(
            future: getData(),
            builder: (context, snap) => StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Posts")
                      .where('userId', isEqualTo: uid)
                      .orderBy('postedOn', descending: true)
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData)
                      return Center(
                          child: SpinKitRipple(
                        color: Colors.grey,
                      ));
                    else
                      return Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Stack(children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(45),
                                        border: Border.all(
                                            color: Colors.grey, width: 2)),
                                    margin: EdgeInsets.only(top: 20),
                                    child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 45,
                                        backgroundImage: dpUrl != null
                                            ? dpUrl != ""
                                                ? CachedNetworkImageProvider(
                                                    dpUrl)
                                                : AssetImage(
                                                    'lib/images/phperson.png')
                                            : AssetImage(
                                                'lib/images/phperson.png')),
                                  ),
                                  Expanded(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ShowData(posts, "Posts"),
                                          ShowData(
                                              (followersList == null ||
                                                      followersList == [])
                                                  ? 0
                                                  : followersList.length,
                                              "Followers"),
                                          ShowData(
                                              (followingList == null ||
                                                      followingList == [])
                                                  ? 0
                                                  : followingList.length,
                                              "Following"),
                                        ]),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 10, left: 10),
                                child: Text(displayName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Theme.of(context).accentColor)),
                              ),
                              Container(
                                height: 30,
                                width: double.infinity,
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(5)),
                                child: FlatButton(
                                  child: Text("Edit Profile",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              Theme.of(context).accentColor)),
                                  onPressed: () {},
                                ),
                              ),
                              if (!snap.hasData || snap.data?.documents.isEmpty)
                                SingleChildScrollView(
                                  child: Center(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2),
                                      child: Column(children: [
                                        Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                          size: 65,
                                        ),
                                        Text("There are no Posts to Display",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.grey)),
                                      ]),
                                    ),
                                  ),
                                )
                              else
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              childAspectRatio: 1 / 1,
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 3,
                                              mainAxisSpacing: 3),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onLongPress: () {
                                            setState(() {
                                              enlarge = true;
                                              img = snap.data?.documents[index]
                                                  ['posturl'];
                                            });
                                          },
                                          onLongPressEnd: (det) {
                                            setState(() {
                                              enlarge = false;
                                            });
                                          },
                                          child: Container(
                                            color: Colors.white,
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: snap.data
                                                  ?.documents[index]['posturl'],
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                'lib/images/placeholder.png',
                                                fit: BoxFit.cover,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: snap.data == null
                                          ? 0
                                          : snap.data.documents.length,
                                    ),
                                  ),
                                ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          if (enlarge) ...[
                            BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 2,
                                sigmaY: 2,
                              ),
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth: double.infinity - 50),
                                child: Center(
                                  child: Column(children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 2),
                                        color: Colors.black,
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10, bottom: 5),
                                            child: CircleAvatar(
                                              backgroundImage: dpUrl != null
                                                  ? dpUrl != ""
                                                      ? CachedNetworkImageProvider(
                                                          dpUrl)
                                                      : AssetImage(
                                                          'lib/images/phperson.png')
                                                  : AssetImage(
                                                      'lib/images/phperson.png'),
                                            ),
                                          ),
                                          Text(userName,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Theme.of(context)
                                                      .accentColor)),
                                        ],
                                      ),
                                    ),
                                    Image.network(
                                      img,
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                          ]
                        ]),
                      );
                  },
                )));
  }
}
