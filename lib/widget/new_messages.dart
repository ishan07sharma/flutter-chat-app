import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  final _messagecontroller = TextEditingController();
  @override
  void dispose() {
    _messagecontroller.dispose();
    super.dispose();
  }

  void _submitmessage() async {
    final enteredMessage = _messagecontroller.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    _messagecontroller.clear();
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser;
    print(user);
    final userdata = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    await FirebaseFirestore.instance.collection('chat').add({
      'userId': user.uid,
      'createdAt': Timestamp.now(),
      'message': enteredMessage,
      'username': userdata.data()!['name'],
      'imageUrl': userdata.data()!['image'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _messagecontroller,
            autocorrect: true,
            textCapitalization: TextCapitalization.sentences,
            enableSuggestions: true,
            decoration: const InputDecoration(label: Text('Send a message...')),
          )),
          IconButton(
              color: Theme.of(context).colorScheme.primary,
              onPressed: _submitmessage,
              icon: const Icon(Icons.send)),
        ],
      ),
    );
  }
}
