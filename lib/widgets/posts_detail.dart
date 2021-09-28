import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:iinstagram/screens/Comments_screen.dart';

class PostsDetails extends StatefulWidget {
  final String uname;
  int likes;
  final String dpUrl;
  final String postUrl;
  final String caption;
  final docId;
  var likedBy = [];
  PostsDetails(this.uname, this.likes, this.dpUrl, this.postUrl, this.caption,
      this.docId, this.likedBy);

  @override
  _PostsDetailsState createState() => _PostsDetailsState();
}

class _PostsDetailsState extends State<PostsDetails> {
  bool isLiked = true;
  bool isEllipsis = true;
  var creatorId;
  var currentUserName;
  final uid = FirebaseAuth.instance.currentUser.uid;
  final FlareControls flareControls = FlareControls();
  toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      if (widget.likes >= 0) {
        isLiked
            ? widget.likes = widget.likes + 1
            : widget.likes = widget.likes - 1;
      }
    });

    if (isLiked && !widget.likedBy.contains(uid)) {
      widget.likedBy.add(uid);
    } else if (!isLiked && widget.likedBy.contains(uid)) {
      widget.likedBy.remove(uid);
    }

    FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.docId)
        .update({'likedBy': widget.likedBy});

    if (isLiked) {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(creatorId)
          .collection("Notifications")
          .add({
        'userName': currentUserName,
        'message': "liked your photo.",
        'dpUrl': widget.dpUrl,
        'notificationTime': Timestamp.now()
      });
    }
  }

  getCreatorId() async {
    await FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.docId)
        .get()
        .then((val) {
      creatorId = val.data()['userId'];
    });
  }

  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .get()
        .then((val) {
      currentUserName = val.data()['userName'];
    });
  }

  @override
  void initState() {
    super.initState();
    getCreatorId();
    getCurrentUser();
    if (widget.likedBy != null || widget.likedBy != []) {
      widget.likedBy.contains(uid) ? isLiked = true : isLiked = false;
    }

    setState(() {});
  }

  Widget build(BuildContext context) {
    print(widget.docId);
    return Column(children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 7),
        child: Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Row(children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12),
                  child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 18,
                      backgroundImage: widget.dpUrl != null
                          ? widget.dpUrl != ""
                              ? CachedNetworkImageProvider(
                                  widget.dpUrl,
                                )
                              : AssetImage('lib/images/phperson.png')
                          : AssetImage('lib/images/phperson.png')),
                ),
                Text(
                  widget.uname,
                  style: TextStyle(
                      fontSize: 18, color: Theme.of(context).accentColor),
                ),
              ]),
              GestureDetector(
                  onDoubleTap: () {
                    toggleLike();
                    flareControls.play("like");
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        child: CachedNetworkImage(
                          useOldImageOnUrlChange: false,
                          imageUrl: widget.postUrl,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                            child: SizedBox(
                              height: 70,
                              width: 70,
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress),
                            ),
                          ),
                          errorWidget: (context, url, error) => Text(
                            "Sorry, This Image couldn't be Loaded",
                            style: TextStyle(color: Colors.grey, fontSize: 20),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: SizedBox(
                          width: 90,
                          height: 90,
                          child: FlareActor(
                            'lib/flares/instagram_like.flr',
                            controller: flareControls,
                            alignment: Alignment.center,
                            animation: 'idle',
                          ),
                        ),
                      ),
                    ],
                  )),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  IconButton(
                      iconSize: 25,
                      color: Theme.of(context).accentColor,
                      icon: FaIcon(isLiked
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart),
                      onPressed: () {
                        toggleLike();
                      }),
                  IconButton(
                      iconSize: 25,
                      color: Theme.of(context).accentColor,
                      icon: FaIcon(FontAwesomeIcons.comment),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Comments(widget.docId)));
                      }),
                  Spacer(),
                  IconButton(
                      iconSize: 25,
                      color: Theme.of(context).accentColor,
                      icon: FaIcon(FontAwesomeIcons.bookmark),
                      onPressed: () {})
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 7),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: widget.likes == 0
                      ? Container()
                      : Text(
                          '${widget.likes} Likes',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                ),
              ),
              widget.caption == ""
                  ? Container()
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Padding(
                              padding: EdgeInsets.only(left: 7, right: 7),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isEllipsis = !isEllipsis;
                                  });
                                },
                                child: RichText(
                                  overflow: widget.caption.length > 30
                                      ? isEllipsis
                                          ? TextOverflow.ellipsis
                                          : TextOverflow.visible
                                      : TextOverflow.visible,
                                  text: TextSpan(
                                    text: '${widget.uname} ',
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: widget.caption,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal)),
                                    ],
                                  ),
                                ),
                              )),
                        ),
                      ],
                    )
            ],
          ),
        ),
      ),
    ]);
  }
}
