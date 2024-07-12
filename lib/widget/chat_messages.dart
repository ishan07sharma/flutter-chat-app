import 'package:chatapp/widget/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});
  @override
  Widget build(BuildContext context) {
    var currentAuthenticateduser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No message'));
          }
          if (chatSnapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          final loadedMessage = chatSnapshot.data!.docs;
          return ListView.builder(
              padding: const EdgeInsets.only(left: 13, right: 13, bottom: 40),
              reverse: true,
              itemCount: loadedMessage.length,
              itemBuilder: (ctx, index) {
                final currentMessage = loadedMessage[index].data();
                final nextMessage = index + 1 < loadedMessage.length
                    ? loadedMessage[index+1].data()
                    : null;
                final nextMessageid =
                    nextMessage != null ? nextMessage['userId'] : null;
                final issame = currentMessage['userId'] == nextMessageid;
                if (issame) {
                  return MessageBubble.next(
                      message: currentMessage['message'],
                      isMe: currentMessage['userId'] ==
                          currentAuthenticateduser!.uid);
                }else{
                  return MessageBubble.first(userImage: currentMessage['imageUrl'], 
                  username: currentMessage['username'],
                   message: currentMessage['message'],
                    isMe:currentMessage['userId'] == currentAuthenticateduser!.uid );

                }
              });
        });
  }
}
