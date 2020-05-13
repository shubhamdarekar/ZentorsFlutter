import 'package:Zentors/Providers/AuthService.dart';
import 'package:Zentors/loginSignup/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final FirebaseUser user;
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  HomePage({Key key, @required this.user})
      : assert(user != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(bottomNavigationBar:new BottomNavigationBar(items: [ BottomNavigationBarItem(title: Text("Appointments"),icon:Icon(
      Icons.audiotrack,
      color: Colors.green,
      size: 30.0,
    )),BottomNavigationBarItem(title: Text("Appointments"),icon:Icon(
      Icons.golf_course,
      color: Colors.red,
      size: 30.0,
    ))]),
      drawer: new Drawer(),
      body: Column(
        children: <Widget>[
          RaisedButton(
            child: Text("Sign out"),
            onPressed: () async  {
              await Provider.of<AuthService>(context,listen: false).logout();
              // _firebaseAuth.currentUser().then((value) => print(value));
            },
          ),
          Center(
            child: Text(user.toString()),
          ),
          RaisedButton(
            child: Text("Test"),
            onPressed: () async  {
              print(Navigator.push(context, CupertinoPageRoute(builder: (context) => AuthScreen(),)));
            },
          ),
        ],
      ),
    );
  }
}
