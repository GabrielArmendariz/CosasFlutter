import 'package:chat/helpers/shared_preferences_helper.dart';
import 'package:chat/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name;
  ChatScreen(this.chatWithUsername, this.name);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  String chatRoomId;
  String messageId;
  String myName, myProfilePic, myUsername, myEmail;
  TextEditingController messageTextController = TextEditingController();
  Stream messageStream;

  getMyInfo() async{
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myProfilePic = await SharedPreferenceHelper().getUserProfile();
    myUsername = await SharedPreferenceHelper().getUserName();
    chatRoomId = getChatRoomId(widget.chatWithUsername, myUsername);
  }

  getChatRoomId(String usernameA, String usernameB){
    var list = [usernameA, usernameB];
    list.sort();
    return list[0]+"_"+list[1];
  }

  addMessage(bool sendClicked){
    if(messageTextController.text != ""){
      String message = messageTextController.text;
      var lastMessageTimestamp = DateTime.now();
      Map<String, dynamic> messageInfo = {
        "message" : message,
        "sendBy" : myUsername,
        "ts" : lastMessageTimestamp,
        "image" : myProfilePic
      };
      if(messageId == ""){
        messageId = randomAlphaNumeric(12);
      }
      DatabaseMethods().addMessage(chatRoomId,messageId,messageInfo)
          .then((value) {
            Map<String, dynamic> info = {
              "lastMessage" : message,
              "lastMessageTimestamp" : lastMessageTimestamp,
              "lastMessageSendBy" : myUsername
            };
            DatabaseMethods().updateLastMessageSend(chatRoomId, info);

            if(sendClicked){
              messageTextController.text = "";
              messageId = "";
            }
      });
    }
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  Widget chatMessages() {
    return StreamBuilder(
        stream: messageStream,
        builder: (context, snapshot){
          return snapshot.hasData ? ListView.builder(
            padding: EdgeInsets.only(bottom: 70),
              itemCount: snapshot.data.docs.length,
              reverse: true,
              itemBuilder: (context, index){
                DocumentSnapshot ds = snapshot.data.docs[index];
                return messageTile(ds["message"], myUsername == ds["sendBy"]);
              }
          ) : Center(
            child: CircularProgressIndicator()
          );
        }
    );
  }

  Widget messageTile(String message, bool mine){
    return Row(
      mainAxisAlignment: mine? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: mine ? Radius.circular(24) : Radius.circular(0),
                bottomRight: mine ? Radius.circular(0) : Radius.circular(24),
            ),
            color: Colors.blueAccent
          ),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(message, style: TextStyle(color: Colors.white))
        ),
      ],
    );
  }

  onLaunch() async{
    await getMyInfo();
    getAndSetMessages();
  }

  @override
  void initState() {
    onLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Container(
        child: Stack(children: [
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.lightBlueAccent.withOpacity(0.8),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    onChanged: addMessage(false),
                    controller: messageTextController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type a message",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400
                      )
                    )
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      addMessage(true);
                    },
                    child: Icon(Icons.send)
                )
              ],)
            ),
          )
        ],)
      ),
    );
  }
}
