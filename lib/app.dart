import 'package:Zentors/IntroSlider/introSlider.dart';
import 'package:Zentors/Providers/AuthService.dart';
import 'package:Zentors/home.dart';
import 'package:Zentors/loginSignup/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<AuthService>(context).getUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // log error to console
            if (snapshot.error != null) {
              print("error");
              return Text(snapshot.error.toString());
            }
            return snapshot.hasData
                ? HomePage(user: snapshot.data)
                : FutureBuilder(
                    future: Provider.of<AuthService>(context).getFirstTime(),
                    builder: (context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // log error to console
                        if (snapshot.error != null) {
                          print("error");
                          return Text(snapshot.error.toString());
                        }
                        return snapshot.data ? IntroScreen() : AuthScreen();
                      } else {
                        // show loading indicator
                        return LoadingCircle();
                      }
                    });
          } else {
            // show loading indicator
            return LoadingCircle();
          }
        });
  }
}

class LoadingCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 500,
        width: 500,
        child: CircularProgressIndicator(),
        alignment: Alignment(0.0, 0.0),
      ),
    );
  }
}

// FutureBuilder<FirebaseUser>(
//             future: Provider.of<AuthService>(context).getUser(),
//             builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
//               if (snapshot.connectionState == ConnectionState.done) {
//                 // log error to console
//                 if (snapshot.error != null) {
//                   print("error");
//                   return Text(snapshot.error.toString());
//                 }
//                 print("error");
//                 return snapshot.hasData
//                     ? HomePage(user: snapshot.data)
//                     : FutureBuilder<bool>(
//                         future:
//                             Provider.of<AuthService>(context).getFirstTime(),
//                         builder: (context, AsyncSnapshot<bool> snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.done) {
//                             // log error to console
//                             if (snapshot.error != null) {
//                               print("error");
//                               return Text(snapshot.error.toString());
//                             }

//                             return snapshot.data ? IntroScreen() : AuthScreen();
//                           } else {
//                             // show loading indicator
//                             return LoadingCircle();
//                           }
//                         },
//                       );
//               } else {
//                 // show loading indicator
//                 return LoadingCircle();
//               }
//             })
