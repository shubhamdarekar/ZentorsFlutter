import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  Future logout() async {
    await googleSignIn.signOut();
    var result = await FirebaseAuth.instance.signOut();
    await getUser();
    notifyListeners();
    return result;
  }

  Future<FirebaseUser> loginUser(
      {String verificationId, String pin, BuildContext context}) async {
    if (verificationId != '') {
      AuthCredential _authCredential = PhoneAuthProvider.getCredential(
          verificationId: verificationId, smsCode: pin);

      await _auth
          .signInWithCredential(_authCredential)
          .then((AuthResult value) {
        if (value.user != null) {
          // Handle loogged in state
          notifyListeners();
          Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
        } else {
          showToast("Error validating OTP, try again", Colors.red);
        }
      }).catchError((e) {
        showToast(e.message, Colors.red);
      });
    } else {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult =
          await _auth.signInWithCredential(credential);
          Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      final FirebaseUser user = authResult.user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
    }
    notifyListeners();
    return _auth.currentUser();
  }

  Future<bool> getFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('firstTime') ?? true;
  }

  Future<bool> setFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstTime', false);
    await getFirstTime();
    notifyListeners();
    return false;
  }

  void showToast(message, Color color) {
    print(message);
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
