import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iinstagram/screens/DM_screen.dart';
import 'package:iinstagram/widgets/posts_detail.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Posts extends StatefulWidget {
  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  _onHorizontalDrag(DragEndDetails details, BuildContext ctx) {
    if (details.primaryVelocity == 0)
      return; // user have just tapped on screen (no dragging)

    if (details.primaryVelocity.compareTo(0) == -1) {
      print('dragged from left');
      Navigator.of(ctx).push(CupertinoPageRoute(builder: (ctx) => DMScreen()));
    } else {
      print('dragged from right');
      //Navigator.of(ctx).push(CupertinoPageRoute(builder: (ctx) => DMScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  var userNames = [];
  var dpUrls = [];
  var followingList = [];
  var postUrls = [];
  var captions = [];
  var postIds = [];
  var userIds = [];
  var likedBy = [];
  var txt = "";
  bool isLoading = false;

  Future getFollowing() async {
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get()
          .then((val) {
        followingList = val.data()['followingList'];
      });
    } catch (err) {
      print(err);
    }
    if (followingList.length == 0) {
      setState(() {
        txt = "Please Follow People to see their Posts!";
      });
    } else {
      setState(() {
        txt = "";
      });
    }
    return [followingList, txt];
  }

  Future getUserDetails(uid) async {
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .get()
          .then((val) {
        userNames.add(val.data()['userName']);
        dpUrls.add(val.data()['dpUrl']);
      });
    } catch (err) {
      print(err);
    }

    return [userNames, dpUrls];
  }

  fetchData() async {
    if (this.mounted) {
      setState(() {
        isLoading = true;
      });
    }

    await getFollowing();
    if (followingList.length > 0) {
      await FirebaseFirestore.instance
          .collection('Posts')
          .where('userId', whereIn: followingList)
          .orderBy('postedOn', descending: true)
          .get()
          .then((val) {
        val.docs.forEach((val2) {
          captions.add(val2.data()['caption']);
          postUrls.add(val2.data()['posturl']);
          postIds.add(val2.data()['postId']);
          userIds.add(val2.data()['userId']);
          likedBy.add(val2.data()['likedBy']);
        });
      });
      for (var i in userIds) {
        await getUserDetails(i);
      }
      if (this.mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
    //print(likedBy);
    return [captions, postUrls, postIds, userIds, likedBy];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) =>
            _onHorizontalDrag(details, context),
        child: Column(children: [
          SizedBox(
            height: 100,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                    left: 15,
                  ),
                  child: Text("Instagram",
                      style: GoogleFonts.grandHotel(
                          textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 45,
                      ))),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                    left: 15,
                  ),
                  child: IconButton(
                    icon: FaIcon(FontAwesomeIcons.telegramPlane),
                    onPressed: () {
                      Navigator.of(context).push(
                          CupertinoPageRoute(builder: (context) => DMScreen()));
                    },
                    color: Colors.white,
                    iconSize: 25,
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? Center(
                  heightFactor: 6,
                  child: Column(children: [
                    SpinKitRipple(
                      color: Colors.grey,
                    ),
                    Text(
                      txt,
                      style: TextStyle(
                          color: Theme.of(context).accentColor, fontSize: 22),
                    )
                  ]),
                )
              : Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: postIds.length,
                      itemBuilder: (context, index) {
                        var likes = likedBy[index].length > 0
                            ? likedBy[index].length
                            : 0;
                        return PostsDetails(
                          userNames[index],
                          likes,
                          dpUrls[index],
                          postUrls[index],
                          captions[index],
                          postIds[index],
                          likedBy[index],
                        );
                      }),
                ),
        ]),
      ),
    );
  }
}
