import 'package:chat/helpers/shared_preferences_helper.dart';
import 'package:chat/services/auth.dart';
import 'package:chat/services/database.dart';
import 'package:chat/views/chatscreen.dart';
import 'package:chat/views/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isSearching = false;
  Stream usersStream;
  Stream chatRoomsStream;
  TextEditingController searchUsername = TextEditingController();
  String myUsername;

  @override
  void initState() {
    // TODO: implement initState
    onScreenLoaded();
    super.initState();
  }

  onScreenLoaded() async{
    await getMyInfo();
    getChatRooms();
  }

  getMyInfo() async{
    myUsername = await SharedPreferenceHelper().getUserName();
  }

  getChatRooms() async{
    chatRoomsStream = await DatabaseMethods().getMyChatRooms();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Firebase Chat App'),
          actions: [
            InkWell(
              onTap: (){
                AuthMethods().signOut().then((s){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignIn()));
                });
              },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.exit_to_app))
            )
          ]
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(children:
              [
                isSearching ? GestureDetector(
                  onTap: (){
                    setState(() {
                      isSearching = false;
                      searchUsername.text = "";
                    });
                  },
                  child: Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.arrow_back)
                  ),
                ) : Container(),
                Expanded(
                  child: Container(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black87,
                        width: 1,
                        style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    children: [Expanded(
                      child: TextField(
                          controller: searchUsername,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "username"
                      ))
                    ),
                    GestureDetector(
                        onTap: () {
                          if(searchUsername.text != ""){                            
                            onSearchBtnClick();
                          }
                        },
                        child: Icon(Icons.search))],
                  ),
              ),)],
            ),
            isSearching ? searchUsersList() : chatsList()
          ]
        )
      )
    );
  }

  onSearchBtnClick() async{
    usersStream = await DatabaseMethods().getUserByUsername(searchUsername.text);
    setState(() {
      isSearching = true;
    });
  }

  getChatRoomId(String usernameA, String usernameB){
    var list = [usernameA, usernameB];
    list.sort();
    return list[0]+"_"+list[1];
  }

  Widget chatsList(){
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context,index){
            DocumentSnapshot ds = snapshot.data.docs[index];
            return ChatRoomTile(ds["lastMessage"],ds.id,myUsername);
          }
        ) : Center(
            child: CircularProgressIndicator()
        );
      }
    );
  }

  Widget userTile(String url, String email, String name, String username){
    return GestureDetector(
      onTap: () async{
        var chatRoomId = getChatRoomId(myUsername,username);
        Map<String, dynamic> chatRoomInfo = {
          "users" : [myUsername, username]
        };
        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfo);
        Navigator.push(context,MaterialPageRoute(
            builder: (context) => ChatScreen(username, name)
        ));
      },
      child: Row(children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(url, height: 30, width: 30)
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name),
              Text(email)
            ],
          )
      ],),
    );
  }
  
  Widget searchUsersList(){
    return StreamBuilder(
        stream: usersStream,
        builder: (context, snapshot){
          return snapshot.hasData ? ListView.builder(
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              itemBuilder: (context,index){
                DocumentSnapshot ds = snapshot.data.docs[index];
                return userTile(ds["profile"], ds["email"], ds["name"], ds["username"]);
              }
          ) : Center(child: CircularProgressIndicator()
          );
        }
    );
  }
}

class ChatRoomTile extends StatefulWidget {

  final String lastMessage;
  final String chatRoomId;
  final String myUsername;

  ChatRoomTile(this.lastMessage,this.chatRoomId, this.myUsername);

  @override
  _ChatRoomTileState createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {

  String profileUrl, name, username;

  getThisUserInfo() async {
    username = widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    name = querySnapshot.docs[0]["name"];
    profileUrl = querySnapshot.docs[0]["profile"];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context,MaterialPageRoute(
            builder: (context) => ChatScreen(username, name)
        ));
      },
      child: Row(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: profileUrl != null ? Image.network(profileUrl, height: 40, width: 40,) : Container()
        ),
        SizedBox(width: 8,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name != null ? name : "", style: TextStyle(fontSize: 16),),
            SizedBox(height: 3,),
            Text(name != null ? widget.lastMessage : ""),
          ],
        )
      ],),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    getThisUserInfo();
    super.initState();
  }
}
