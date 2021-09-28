import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iinstagram/screens/Auth_Screen.dart';
import 'package:iinstagram/widgets/tab.dart';
import 'package:image_picker/image_picker.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  FToast fToast;
  final email = TextEditingController();
  final pass = TextEditingController();
  final userName = TextEditingController();
  final displayName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  var userNameSearchList = [];
  final userNameFN = FocusNode();
  final displayNameFN = FocusNode();
  final passwordFN = FocusNode();
  final appHeight = AppBar().preferredSize.height;
  var uid;
  var dpUrl;
  var temp = "";
  bool isLoading = false;
  ImagePicker picker = ImagePicker();
  PickedFile img;
  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  Future pickImage(ImageSource src) async {
    img = await picker.getImage(source: src, imageQuality: 70);
    setState(() {});
  }

  checkEmail(email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(email);
  }

  void chooseImage() {
    showModalBottomSheet(
        backgroundColor: Colors.grey.withOpacity(0.1),
        context: context,
        builder: (BuildContext context) {
          return Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.20),
            child: Column(children: [
              Divider(
                color: Colors.white,
                endIndent: MediaQuery.of(context).size.width * 0.45,
                indent: MediaQuery.of(context).size.width * 0.45,
                thickness: 2.5,
              ),
              GestureDetector(
                onTap: () => pickImage(ImageSource.gallery),
                child: ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: Theme.of(context).accentColor,
                  ),
                  title: Text(
                    "Upload From Gallery",
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => pickImage(ImageSource.camera),
                child: ListTile(
                  leading: Icon(
                    Icons.camera,
                    color: Theme.of(context).accentColor,
                  ),
                  title: Text(
                    "Upload From Camera",
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
              ),
            ]),
          );
        });
  }

  getUserKeys() {
    userNameSearchList = [];
    temp = "";
    var uname = "";
    uname = userName.text.toLowerCase();
    for (var i = 0; i < uname.length; i++) {
      temp = temp + uname[i];
      userNameSearchList.add(temp);
    }
    print(userNameSearchList);
  }

  var checkedUser;
  checkUserName(uname) async {
    checkedUser = "";
    await FirebaseFirestore.instance
        .collection("Users")
        .where('userName', isEqualTo: uname)
        .get()
        .then((val) {
      val.docs.forEach((val2) {
        checkedUser = val2.data()['userName'];
      });
    });
    return checkedUser;
  }

  void signUp() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState.save();
      try {
        await auth.createUserWithEmailAndPassword(
            email: email.text.trim(), password: pass.text.trim());
      } on FirebaseAuthException catch (firebaseEx) {
        print(firebaseEx.message);
        fToast.showToast(
          gravity: ToastGravity.SNACKBAR,
          toastDuration: Duration(seconds: 5),
          child: Text(firebaseEx.message,
              style: TextStyle(
                  color: Theme.of(context).accentColor, fontSize: 16)),
        );
      } catch (err) {
        print(err);
      }
      setState(() {
        isLoading = false;
      });
      uid = FirebaseAuth.instance.currentUser.uid;
      try {
        var ref = FirebaseStorage.instance
            .ref()
            .child(uid)
            .child(img.path + Timestamp.now().toString());
        await ref.putFile(File(img.path));
        dpUrl = await ref.getDownloadURL();
      } catch (err) {
        print(err);
      }
      await getUserKeys();
      try {
        FirebaseFirestore.instance.collection("Users").doc(uid).set({
          "mail": email.text.trim().toLowerCase(),
          "userName": userName.text.trim().toLowerCase(),
          "displayName": displayName.text.trim().toLowerCase(),
          "dpUrl": dpUrl,
          "regDate": DateTime.now(),
          "searchKeys": userNameSearchList,
          "posts": 0,
          "followersList": [],
          "followingList": [],
          "pendingRequests": [],
          "userId": uid,
          "isPrivate": true,
        });
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Tabbarr()));
      } catch (err) {
        print(err);
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text("Create New Account"),
      ),
      body: isLoading
          ? SpinKitRipple(
              color: Colors.grey,
            )
          : SingleChildScrollView(
              child: Container(
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      margin: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Text("Instagram",
                                style: GoogleFonts.grandHotel(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 60,
                                  ),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: img?.path != null
                                  ? FileImage(File(img?.path))
                                  : AssetImage('lib/images/phperson.png'),
                              backgroundColor: Colors.grey.withOpacity(0.4),
                            ),
                          ),
                          FlatButton(
                            child: Text(
                              "Upload Display Picture",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).accentColor),
                            ),
                            onPressed: () => chooseImage(),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              top: 20,
                              left: MediaQuery.of(context).size.width * 0.1,
                              right: MediaQuery.of(context).size.width * 0.1,
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              controller: email,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.4),
                                  hintText: "Email",
                                  errorStyle: TextStyle(fontSize: 15),
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 20)),
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(userNameFN);
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Enter Email";
                                } else if (!checkEmail(value)) {
                                  return "Enter the Email in Proper Format";
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              top: 20,
                              left: MediaQuery.of(context).size.width * 0.1,
                              right: MediaQuery.of(context).size.width * 0.1,
                            ),
                            child: TextFormField(
                              focusNode: userNameFN,
                              onChanged: (val) async {
                                await checkUserName(val.toLowerCase());
                                setState(() {});
                                if (checkedUser == null || checkedUser == "") {
                                  print("username avail");
                                } else {
                                  print("userName Unavailable");
                                }
                              },
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              controller: userName,
                              decoration: InputDecoration(
                                labelText: (userName.text.length > 0)
                                    ? ((checkedUser == null ||
                                                checkedUser == "") &&
                                            userName.text.length >= 4)
                                        ? "User Name Available"
                                        : "User Name Not Available"
                                    : "User Name",
                                labelStyle: TextStyle(
                                    color: (userName.text.length > 0)
                                        ? ((checkedUser == null ||
                                                checkedUser == "" &&
                                                    userName.text.length >= 4))
                                            ? Colors.green
                                            : Theme.of(context).errorColor
                                        : Colors.grey,
                                    fontSize: 20),
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.4),
                                errorStyle: TextStyle(fontSize: 15),
                              ),
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(displayNameFN);
                              },
                              validator: (val) {
                                if (val.isEmpty) {
                                  return "Enter User Name";
                                } else if (val.length < 4) {
                                  return "User Name must contain 4 characters";
                                } else if (val.contains(" ")) {
                                  return "White Spaces not allowed";
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              top: 20,
                              left: MediaQuery.of(context).size.width * 0.1,
                              right: MediaQuery.of(context).size.width * 0.1,
                            ),
                            child: TextFormField(
                              focusNode: displayNameFN,
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              controller: displayName,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.4),
                                  hintText: "Display Name",
                                  errorStyle: TextStyle(fontSize: 15),
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 20)),
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(passwordFN);
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Enter DisplayName";
                                } else if (value.contains(" ")) {
                                  return "White Spaces not allowed";
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              top: 20,
                              left: MediaQuery.of(context).size.width * 0.1,
                              right: MediaQuery.of(context).size.width * 0.1,
                            ),
                            child: TextFormField(
                              focusNode: passwordFN,
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              controller: pass,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.4),
                                  hintText: "Password",
                                  errorStyle: TextStyle(fontSize: 15),
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 20)),
                              onFieldSubmitted: (_) {
                                signUp();
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Enter Password";
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 1,
                            height: 70,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 20,
                                left: MediaQuery.of(context).size.width * 0.1,
                                right: MediaQuery.of(context).size.width * 0.1,
                              ),
                              child: RaisedButton(
                                onPressed: () => signUp(),
                                child: Text(
                                  "SignUp",
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 20,
                                  ),
                                ),
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Already have an Account?",
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontSize: 18)),
                                TextButton(
                                  child: Text("Login",
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                          fontSize: 18)),
                                  onPressed: () => Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                          builder: (context) => AuthScreen())),
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
                  key: _formKey,
                ),
              ),
            ),
    );
  }
}
