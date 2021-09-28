import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iinstagram/widgets/showData.dart';

class SearchedUser extends StatefulWidget {
  final uid;
  SearchedUser(this.uid);
  @override
  _SearchedUserState createState() => _SearchedUserState();
}

class _SearchedUserState extends State<SearchedUser> {
  var userName = "";
  var displayName = "";
  var dpUrl = "";
  var posts = 0;
  var pendingRequests = [];
  var followersList = [];
  var followingList = [];
  final currentUid = FirebaseAuth.instance.currentUser.uid;
  var currentFollowing;
  bool isPrivate = true;
  bool requested = false;
  bool followed = false;

  unFollow() async {
    setState(() {
      followed = false;
    });
    if (followed == false && followersList.contains(currentUid)) {
      followersList.remove(currentUid);
    }
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.uid)
          .update({
        "followersList": followersList,
      });
      setState(() {});
    } catch (err) {
      print(err);
    }
  }

  followedDirect() async {
    setState(() {
      followed = !followed;
    });

    if (followed == true && !followersList.contains(currentUid)) {
      followersList.add(currentUid);
    } else if (followed == false && followersList.contains(currentUid)) {
      followersList.remove(currentUid);
    }

    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.uid)
          .update({
        "followersList": followersList,
      });
      setState(() {});
    } catch (err) {
      print(err);
    }
  }

  updateFollowing() async {
    if (followed == true && !currentFollowing.contains(widget.uid)) {
      currentFollowing.add(widget.uid);
    } else if (followed == false && currentFollowing.contains(widget.uid)) {
      currentFollowing.remove(widget.uid);
    }
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUid)
        .update({"followingList": currentFollowing});
  }

  sendRequest() async {
    setState(() {
      requested = !requested;
    });
    if (requested == true && !pendingRequests.contains(currentUid)) {
      pendingRequests.add(currentUid);
    } else if (requested == false && pendingRequests.contains(currentUid)) {
      pendingRequests.remove(currentUid);
    }
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.uid)
        .update({"pendingRequests": pendingRequests});
    print(pendingRequests);
  }

  Future getData() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.uid)
        .get()
        .then((snap) => {
              userName = snap.data()['userName'],
              displayName = snap.data()['displayName'],
              dpUrl = snap.data()['dpUrl'],
              posts = snap.data()['posts'],
              followersList = snap.data()['followersList'],
              followingList = snap.data()['followingList'],
              pendingRequests = snap.data()['pendingRequests'],
              isPrivate = snap.data()['isPrivate'],
            });
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUid)
        .get()
        .then((val) {
      currentFollowing = val.data()['followingList'];
    });
    // print(followersList);
    if (followersList != null || followersList != [])
      followersList.contains(currentUid) ? followed = true : followed = false;
    if (pendingRequests != null || pendingRequests != [])
      pendingRequests.contains(currentUid)
          ? requested = true
          : requested = false;
    // print(followed);
    setState(() {});
    return [
      userName,
      displayName,
      dpUrl,
      posts,
      followersList,
      followingList,
      isPrivate,
    ];
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
      ),
      body: FutureBuilder(
          future: getData(),
          builder: (context, snap) => StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Posts")
                    .where('userId', isEqualTo: widget.uid)
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
                      child: Column(
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
                                            ? CachedNetworkImageProvider(dpUrl)
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
                                    color: (() {
                                  if (isPrivate) {
                                    if (followed) {
                                      return Colors.grey;
                                    } else if (!followed && !requested) {
                                      return Colors.blue;
                                    } else if (!followed && requested) {
                                      return Colors.grey;
                                    }
                                  }
                                  if (!isPrivate) {
                                    if (followed) {
                                      return Colors.grey;
                                    } else if (!followed) {
                                      return Colors.blue;
                                    }
                                  }
                                }())),
                                borderRadius: BorderRadius.circular(5)),
                            child: FlatButton(
                              color: (() {
                                if (isPrivate) {
                                  if (followed) {
                                    return Colors.grey;
                                  } else if (!followed && !requested) {
                                    return Colors.blue;
                                  } else if (!followed && requested) {
                                    return Colors.grey;
                                  }
                                }
                                if (!isPrivate) {
                                  if (followed) {
                                    return Colors.grey;
                                  } else if (!followed) {
                                    return Colors.blue;
                                  }
                                }
                              }()),
                              child: (() {
                                if (isPrivate) {
                                  if (followed) {
                                    return Text("Following",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Theme.of(context).accentColor));
                                  } else if (!followed && !requested) {
                                    return Text("Send Request",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Theme.of(context).accentColor));
                                  } else if (!followed && requested) {
                                    return Text("Requested",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Theme.of(context).accentColor));
                                  }
                                }
                                if (!isPrivate) {
                                  if (followed) {
                                    return Text("Following",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Theme.of(context).accentColor));
                                  } else if (!followed) {
                                    return Text("Follow",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Theme.of(context).accentColor));
                                  }
                                }
                              }()),
                              onPressed: () {
                                if (isPrivate) {
                                  if (!followed) {
                                    sendRequest();
                                  }
                                  if (followed) {
                                    unFollow();
                                    updateFollowing();
                                  }
                                } else if (!isPrivate) {
                                  followedDirect();
                                  updateFollowing();
                                }
                              },
                            ),
                          ),
                          (() {
                            if (isPrivate) {
                              if (followed) {
                                if (!snap.hasData ||
                                    snap.data?.documents.isEmpty) {
                                  return SingleChildScrollView(
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
                                  );
                                } else {
                                  return Expanded(
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
                                          return Container(
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
                                          );
                                        },
                                        itemCount: snap.data == null
                                            ? 0
                                            : snap.data.documents.length,
                                      ),
                                    ),
                                  );
                                }
                              }
                              if (!followed) {
                                return SingleChildScrollView(
                                  child: Center(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2),
                                      child: Column(children: [
                                        Icon(
                                          Icons.lock,
                                          color: Colors.grey,
                                          size: 65,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 40),
                                          child: Text(
                                              "This Account is Private.Follow them to see their Photos and Videos",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.grey)),
                                        ),
                                      ]),
                                    ),
                                  ),
                                );
                              }
                            } else if (!isPrivate) {
                              if (!snap.hasData ||
                                  snap.data?.documents.isEmpty && !isPrivate) {
                                return SingleChildScrollView(
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
                                );
                              } else {
                                return Expanded(
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
                                        return Container(
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
                                        );
                                      },
                                      itemCount: snap.data == null
                                          ? 0
                                          : snap.data.documents.length,
                                    ),
                                  ),
                                );
                              }
                            }
                          }())

                          // if (!snap.hasData ||
                          //     snap.data?.documents.isEmpty && !isPrivate)
                          //   SingleChildScrollView(
                          //     child: Center(
                          //       child: Container(
                          //         margin: EdgeInsets.only(
                          //             top: MediaQuery.of(context).size.height *
                          //                 0.2),
                          //         child: Column(children: [
                          //           Icon(
                          //             Icons.image,
                          //             color: Colors.grey,
                          //             size: 65,
                          //           ),
                          //           Text("There are no Posts to Display",
                          //               style: TextStyle(
                          //                   fontSize: 20, color: Colors.grey)),
                          //         ]),
                          //       ),
                          //     ),
                          //   )
                          // else if (isPrivate && !followed)
                          //   SingleChildScrollView(
                          //     child: Center(
                          //       child: Container(
                          //         margin: EdgeInsets.only(
                          //             top: MediaQuery.of(context).size.height *
                          //                 0.2),
                          //         child: Column(children: [
                          //           Icon(
                          //             Icons.lock,
                          //             color: Colors.grey,
                          //             size: 65,
                          //           ),
                          //           SizedBox(
                          //             height: 20,
                          //           ),
                          //           Container(
                          //             padding:
                          //                 EdgeInsets.symmetric(horizontal: 40),
                          //             child: Text(
                          //                 "This Account is Private.Follow them to see their Photos and Videos",
                          //                 style: TextStyle(
                          //                     fontSize: 20,
                          //                     color: Colors.grey)),
                          //           ),
                          //         ]),
                          //       ),
                          //     ),
                          //   )

                          // else
                          //   Expanded(
                          //     child: Padding(
                          //       padding: EdgeInsets.only(top: 10, bottom: 10),
                          //       child: GridView.builder(
                          //         gridDelegate:
                          //             SliverGridDelegateWithFixedCrossAxisCount(
                          //                 childAspectRatio: 1 / 1,
                          //                 crossAxisCount: 3,
                          //                 crossAxisSpacing: 3,
                          //                 mainAxisSpacing: 3),
                          //         itemBuilder: (context, index) {
                          //           return Container(
                          //             color: Colors.white,
                          //             child: CachedNetworkImage(
                          //               fit: BoxFit.cover,
                          //               imageUrl: snap.data?.documents[index]
                          //                   ['posturl'],
                          //               placeholder: (context, url) =>
                          //                   Image.asset(
                          //                 'lib/images/placeholder.png',
                          //                 fit: BoxFit.cover,
                          //               ),
                          //               errorWidget: (context, url, error) =>
                          //                   Icon(Icons.error),
                          //             ),
                          //           );
                          //         },
                          //         itemCount: snap.data == null
                          //             ? 0
                          //             : snap.data.documents.length,
                          //       ),
                          //     ),
                          //   )
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    );
                },
              )),
    );
  }
}
