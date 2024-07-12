import 'package:chatapp/widget/chat_messages.dart';
import 'package:chatapp/widget/new_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void pushnotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    //final token = await fcm.getToken();
    fcm.subscribeToTopic('chat');
    //print(token);
  }

  @override
  void initState() {
    super.initState();
    pushnotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout,
                color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: const Column(
        children: [Expanded(child: ChatMessages()), NewMessages()],
      ),
    );
  }
}
