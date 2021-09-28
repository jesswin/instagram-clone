import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iinstagram/screens/signUp.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final auth = FirebaseAuth.instance;
  final _password = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final uname = TextEditingController();
  final pass = TextEditingController();
  FToast fToast;
  bool auto = false;
  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  allOk() async {
    auto = true;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: uname.text, password: pass.text);
      } on FirebaseAuthException catch (err) {
        print(err.message);
        fToast.removeQueuedCustomToasts();
        fToast.showToast(
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 5),
          child: Text(err.message,
              style: TextStyle(
                  color: Theme.of(context).accentColor, fontSize: 16)),
        );
      } catch (error) {
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Form(
                // ignore: deprecated_member_use
                key: _formKey,
                // ignore: deprecated_member_use
                autovalidate: auto,
                child: Column(children: [
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
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.1,
                        right: MediaQuery.of(context).size.width * 0.1,
                        top: 30),
                    child: TextFormField(
                      controller: uname,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.4),
                          hintText: "Username",
                          errorStyle: TextStyle(fontSize: 15),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 20)),
                      onFieldSubmitted: (_) {
                        auto = true;
                        FocusScope.of(context).requestFocus(_password);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Enter Username";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.1,
                        right: MediaQuery.of(context).size.width * 0.1,
                        top: 20),
                    child: TextFormField(
                      controller: pass,
                      onChanged: (_) {
                        setState(() {});
                      },
                      enableSuggestions: false,
                      obscureText: true,
                      focusNode: _password,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.4),
                          hintText: "Password",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 20),
                          errorStyle: TextStyle(fontSize: 15)),
                      onFieldSubmitted: (_) {
                        allOk();
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Enter Password";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                ]),
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
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      allOk();
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 20,
                      ),
                    ),
                    color: Colors.blue,
                  ),
                ),
              ),
              Spacer(),
              Divider(
                thickness: 1,
                color: Colors.grey,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Dont have an Account?",
                      style: TextStyle(
                          color: Theme.of(context).accentColor, fontSize: 18)),
                  TextButton(
                    child: Text("SignUp",
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 18)),
                    onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => SignUp())),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
