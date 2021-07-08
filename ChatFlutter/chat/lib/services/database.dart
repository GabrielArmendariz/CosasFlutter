import 'package:chat/helpers/shared_preferences_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseMethods{

  Future addUserInfo(String userId, Map<String, dynamic> userInfo) async {
    return await FirebaseFirestore.instance.collection("users").doc(userId).set(userInfo);
  }
  
  Future<Stream<QuerySnapshot>> getUserByUsername(String username) async{
    return FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .snapshots();
  }

  Future addMessage(String chatRoomId, String messageId, Map messageInfo) async{
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId).collection("chats")
        .doc(messageId)
        .set(messageInfo);
  }

  updateLastMessageSend(String chatRoomId, Map messageInfo) async{
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .update(messageInfo);
  }

  createChatRoom(String chatRoomId, Map chatRoomInfo) async{
    final snapshot =  await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .get();
    if(snapshot.exists){
      return true;
    }else{
      return FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomId)
          .set(chatRoomInfo);
    }
  }
  
  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("ts", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getMyChatRooms() async {
    String myUsername = await SharedPreferenceHelper().getUserName();
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .orderBy("lastMessageTimestamp", descending: true)
        .where("users", arrayContains: myUsername)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String username) async{
    return FirebaseFirestore.instance
        .collection("users")
        .where("username",isEqualTo: username)
        .get();
  }
}