import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class Details extends StatefulWidget {
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  Firestore _store = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseUser user;
  File _image;

  @override
  void initState() {
    super.initState();
    _get();
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Future uploadImage() async {
    StorageReference ref = _storage.ref().child("profilePics/" + user.uid);
    ref.putFile(_image);
    await ref.getDownloadURL().then((value) {
      print(value);
      UserUpdateInfo profile = new UserUpdateInfo();
      profile.photoUrl = value;
      user.updateProfile(profile);
      user.reload();
      _store
          .collection("users")
          .document(user.uid)
          .updateData({"profile_picture": value});
    });
    
    this._get();
    print("done");
  }

  _get() async {
    await _auth.currentUser().then((value) => this.setState(() {
          this.user = value;
        }));
  }

  bool isValid = false;
  bool isUpdating = false;
  Future<Null> validate() async {
    if (_displayNameController.text.length >= 2) {
      this.setState(() {
        isValid = true;
      });
    } else {
      this.setState(() {
        isValid = false;
      });
    }
  }

  final TextEditingController _displayNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          children: <Widget>[
            Material(
              elevation: 4.0,
              shape: CircleBorder(),
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: Ink.image(
                image: NetworkImage(user != null ? user.photoUrl : ""),
                fit: BoxFit.cover,
                width: 120.0,
                height: 120.0,
                child: InkWell(
                  onTap: () async {
                    await getImage();
                    await uploadImage();
                  },
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              color: Colors.black,
              child: ExpansionTile(
                children: <Widget>[
                  Container(
                      color: Colors.white,
                      height: 75,
                      margin: EdgeInsets.all(16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _displayNameController,
                              autofocus: true,
                              onChanged: (text) {
                                validate();
                              },
                              decoration: InputDecoration(
                                labelText: "Enter Changed Name",
                              ),
                              autovalidate: true,
                              autocorrect: false,
                              maxLengthEnforced: true,
                              validator: (value) {
                                return !isValid
                                    ? 'Please atleaset 2 characters'
                                    : null;
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(4.0),
                            child: RaisedButton(
                              color: !isValid
                                  ? Theme.of(context).primaryColor
                                  : Colors.green,
                              child: isUpdating
                                  ? Container(
                                      child: CircularProgressIndicator())
                                  : Text("Update"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2.0)),
                              onPressed: () async {
                                this.setState(() {
                                  this.isUpdating = true;
                                });
                                UserUpdateInfo profile = new UserUpdateInfo();
                                profile.displayName =
                                    _displayNameController.text;
                                await user.updateProfile(profile);
                                await user.reload();
                                await _store
                                    .collection('users')
                                    .document(user.uid)
                                    .updateData(
                                        {"name": _displayNameController.text});
                                await _get();
                                this.setState(() {
                                  this.isUpdating = false;
                                });
                              },
                            ),
                          )
                        ],
                      )),
                ],
                // onTap: () {
                //   //open edit profile
                // },
                title: Center(
                  child: Text(
                    user != null ? user.displayName!=null?user.displayName:"sss" : "loading",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Card(
              elevation: 4.0,
              margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.lock_outline,
                      color: Colors.purple,
                    ),
                    title: Text("Change Password"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      //open change password
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.language,
                      color: Colors.purple,
                    ),
                    title: Text("Change Language"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      //open change language
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.purple,
                    ),
                    title: Text("Change Location"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      //open change location
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // child: FutureBuilder(
      //   future: _auth.currentUser(),
      //   builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
      //     if (snapshot.connectionState == ConnectionState.done) {
      //       // log error to console
      //       if (snapshot.error != null) {
      //         print("error");
      //         return Text(snapshot.error.toString());
      //       }
      //       return Center(
      //         child: Column(
      //           children: <Widget>[
      //             Material(
      //               elevation: 4.0,
      //               shape: CircleBorder(),
      //               clipBehavior: Clip.hardEdge,
      //               color: Colors.transparent,
      //               child: Ink.image(
      //                 image: NetworkImage(snapshot.data.photoUrl),
      //                 fit: BoxFit.cover,
      //                 width: 120.0,
      //                 height: 120.0,
      //                 child: InkWell(
      //                   onTap: () {},
      //                 ),
      //               ),
      //             ),
      //             SizedBox(
      //               height: 10,
      //             ),
      //             Card(
      //               elevation: 8.0,
      //               shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(10.0)),
      //               color: Colors.black,
      //               child: ExpansionTile(
      //                 children: <Widget>[
      //                   Container(color: Colors.white,height: 50, margin: EdgeInsets.all(16),
      //                   child: TextFormField(
      //                               keyboardType: TextInputType.number,
      //                               controller: _displayNameController,
      //                               onChanged: (text) {
      //                                 // validate(state);
      //                               },
      //                               decoration: InputDecoration(
      //                                 labelText: "10 digit mobile number",
      //                                 prefix: Container(
      //                                   padding: EdgeInsets.all(4.0),
      //                                   child: Text(
      //                                     "+91",
      //                                     style: TextStyle(
      //                                         color: Colors.black,
      //                                         fontWeight: FontWeight.bold),
      //                                   ),
      //                                 ),
      //                               ),
      //                               autovalidate: true,
      //                               autocorrect: false,
      //                               maxLengthEnforced: true,
      //                               validator: (value) {
      //                                 return 'Please atleaset 2 characters';

      //                               },
      //                             ),
      //                   ),

      //                 ],
      //                 // onTap: () {
      //                 //   //open edit profile
      //                 // },
      //                 title: Center(
      //                   child: Text(
      //                     snapshot.data.displayName,
      //                     style: TextStyle(
      //                       color: Colors.white,
      //                       fontWeight: FontWeight.w500,
      //                     ),
      //                   ),
      //                 ),
      //                 trailing: Icon(
      //                   Icons.edit,
      //                   color: Colors.white,
      //                 ),
      //               ),
      //             ),
      //             const SizedBox(height: 10.0),
      //             Card(
      //               elevation: 4.0,
      //               margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
      //               shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(10.0)),
      //               child: Column(
      //                 children: <Widget>[
      //                   ListTile(
      //                     leading: Icon(
      //                       Icons.lock_outline,
      //                       color: Colors.purple,
      //                     ),
      //                     title: Text("Change Password"),
      //                     trailing: Icon(Icons.keyboard_arrow_right),
      //                     onTap: () {
      //                       //open change password
      //                     },
      //                   ),
      //                   _buildDivider(),
      //                   ListTile(
      //                     leading: Icon(
      //                       FontAwesomeIcons.language,
      //                       color: Colors.purple,
      //                     ),
      //                     title: Text("Change Language"),
      //                     trailing: Icon(Icons.keyboard_arrow_right),
      //                     onTap: () {
      //                       //open change language
      //                     },
      //                   ),
      //                   _buildDivider(),
      //                   ListTile(
      //                     leading: Icon(
      //                       Icons.location_on,
      //                       color: Colors.purple,
      //                     ),
      //                     title: Text("Change Location"),
      //                     trailing: Icon(Icons.keyboard_arrow_right),
      //                     onTap: () {
      //                       //open change location
      //                     },
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),
      //       );
      //     } else
      //       return LoadingCircle();
      //   },
      // )
    );
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade400,
    );
  }
}
