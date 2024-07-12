import 'dart:io';

import 'package:chatapp/widget/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isloading = false;
  File? pickedimage;
  var _islogin = true;
  final _formkey = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  var _username = '';
  void _onsubmit() async {
    if (!_formkey.currentState!.validate() ||
        (!_islogin && pickedimage == null)) {
      return;
    }

    _formkey.currentState!.save();
    try {
      setState(() {
        _isloading = true;
      });
      if (_islogin) {
           await _firebase.signInWithEmailAndPassword(
            email: _email, password: _password);
        //print(userCredentials);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _email, password: _password);

        final storageref = FirebaseStorage.instance
            .ref()
            .child('users_images')
            .child('${userCredentials.user!.uid}.jpeg');
        await storageref.putFile(pickedimage!);
        final imageUrl = await storageref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set(
              {
                'email': _email,
                'name': _username,
                'image': imageUrl,
              },
            );
        //print(imageUrl);
      }
    } on FirebaseAuthException catch (e) {
      // if(e.code=='email-already-in-use'){

      // }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).clearSnackBars();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'Authorization failed'),
      ));
      setState(() {
        _isloading = false;
      });
    }

    //print(_email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                      bottom: 20, top: 30, left: 20, right: 20),
                  width: 200,
                  child: Image.asset('assets/images/chat.png'),
                ),
                Card(
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                          key: _formkey,
                          child: Column(
                            children: [
                              if (!_islogin)
                                UserImagePicker(
                                  onpickimage: (image) {
                                    pickedimage = image;
                                  },
                                ),
                              TextFormField(
                                decoration:
                                    const InputDecoration(labelText: 'Email'),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _email = newValue!;
                                },
                              ),
                              if(!_islogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Username'),
                                enableSuggestions: false,
                                validator: (value) {
                                   if (value == null ||
                                       value.trim().isEmpty ||
                                       value.length < 6) {
                                     return 'Username characters should be at least 6 characters';
                                   }
                                   return null;
                                },
                                onSaved: (newValue) {
                                  _username = newValue!;
                    
                                },
                                ),

                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Password'),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      value.length < 6) {
                                    return 'Password characters should be at least 6 characters';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _password = newValue!;
                                },
                              ),
                              const SizedBox(height: 12),
                              if (_isloading) const CircularProgressIndicator(),
                              if (!_isloading)
                                ElevatedButton(
                                  onPressed: _onsubmit,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer),
                                  child: Text(_islogin ? 'Login' : 'Signup'),
                                ),
                              if (!_isloading)
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _islogin = !_islogin;
                                      });
                                    },
                                    child: Text(_islogin
                                        ? 'Create an account'
                                        : 'I already have an account'))
                            ],
                          )),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
