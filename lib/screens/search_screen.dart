import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iinstagram/screens/searchedUser_Screen.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var userName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextFormField(
              onChanged: (val) {
                setState(() {
                  userName = val;
                });
              },
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(15))),
                  hintText: "Search",
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).accentColor,
                  ),
                  fillColor: Colors.grey.withOpacity(0.3),
                  filled: true,
                  hintStyle: TextStyle(
                      color: Theme.of(context).accentColor, fontSize: 16)),
            ),
          ),
        ),
        StreamBuilder(
          stream: (userName != null && userName != "")
              ? FirebaseFirestore.instance
                  .collection("Users")
                  .where(
                    'searchKeys',
                    arrayContains: userName,
                  )
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection("Users")
                  .where("userId",
                      isNotEqualTo: FirebaseAuth.instance.currentUser.uid)
                  .snapshots(),
          builder: (context, snap) {
            return !snap.hasData
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            print("tap");
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SearchedUser(
                                    snap.data.docs[index]['userId'])));
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: snap.data.docs[index]
                                            ['dpUrl'] !=
                                        null
                                    ? NetworkImage(
                                        snap.data.docs[index]['dpUrl'])
                                    : AssetImage('lib/images/phperson.png')),
                            title: Text(
                              snap.data.docs[index]['userName'],
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              snap.data.docs[index]['displayName'],
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).accentColor),
                            ),
                          ),
                        );
                      },
                      itemCount: snap.data.docs.length,
                    ),
                  );
          },
        )
      ]),
    );
  }
}
