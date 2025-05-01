import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({Key? key}) : super(key: key);

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {

  List<String> activeUsersUidList = [];
  List<String> blockedUsersUidList = [];

  Future<void> getActiveUsersList() async{
    await FirebaseFirestore.instance.collection("ActiveUsersUid").get().then((event) {
      activeUsersUidList.clear();
      activeUsersBasicInfoList.clear();
      if(!mounted){
        return;
      }
      for(int i = 0; i< event.size; i++){
        setState((){
          activeUsersUidList.add(event.docs[i].id);
        });
      }
      getActiveUsersBasicInfo();
    });
  }

  Future<void> getBlockedUsersList() async{
    await FirebaseFirestore.instance.collection("BlockedUsersUid").get().then((event) {
      blockedUsersUidList.clear();
      blockedUsersBasicInfoList.clear();
      if(!mounted){
        return;
      }
      for(int i = 0; i< event.size; i++){
        setState((){
          blockedUsersUidList.add(event.docs[i].id);
        });
      }
      getBlockedUsersBasicInfo();
    });
  }

  List<UserBasicInfo> activeUsersBasicInfoList = [];
  List<UserBasicInfo> blockedUsersBasicInfoList = [];

  Future<void> getActiveUsersBasicInfo() async{
    activeUsersBasicInfoList.clear();
    for(String uid in activeUsersUidList){
      await FirebaseFirestore.instance.collection("Users").doc(uid).collection("BasicInfo").doc(uid).get().then((event) {
        if(!mounted){
          return;
        }
        setState((){
          activeUsersBasicInfoList.add(UserBasicInfo.fromJson(event.data()!));
        });
      });
    }
  }

  Future<void> getBlockedUsersBasicInfo() async{
    blockedUsersBasicInfoList.clear();
    for(String uid in blockedUsersUidList){
      await FirebaseFirestore.instance.collection("Users").doc(uid).collection("BasicInfo").doc(uid).get().then((event) {
        if(!mounted){
          return;
        }
        setState((){
          blockedUsersBasicInfoList.add(UserBasicInfo.fromJson(event.data()!));
        });
      });
    }
  }


  @override
  void initState(){

    getActiveUsersList();
    getBlockedUsersList();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users list"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: const Center(child: Text(
              "Active Users",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ),
          ),


          ListView.builder(
            itemCount: activeUsersBasicInfoList.length,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemBuilder: (context, index) => activeUserLayout(activeUsersBasicInfoList[index]),),

          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: const Center(child: Text(
              "Blocked Users",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ),
          ),

          ListView.builder(
            itemCount: blockedUsersBasicInfoList.length,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemBuilder: (context, index) => blockedUserLayout(blockedUsersBasicInfoList[index]),),
        ],
      ),
    );
  }

  Widget activeUserLayout(UserBasicInfo userBasicInfo){
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
            child: userBasicInfo.profileImageUrl.isEmpty
                ? CircleAvatar(
              radius: 60,
              backgroundImage: userBasicInfo.gender == "Male"
                  ? const AssetImage(
                  'assets/male_profile_image.png')
                  : const AssetImage(
                'assets/female_profile_image.png',),
              // child: ClipOval(
              //   child: widget.userBasicInfo.gender == "Male"
              //       ? Image.asset(
              //           "assets/male_profile_image.png",
              //           fit: BoxFit.fill,
              //         )
              //       : Image.asset(
              //           "assets/female_profile_image.png",
              //           fit: BoxFit.fill,
              //         ),
              // ),
            )
                : CircleAvatar(
              radius: 60,
              // child: ClipOval(
              //   child: Image.network(
              //     widget.userBasicInfo.profileImageUrl,
              //     fit: BoxFit.fill,
              //   ),
              // ),
              backgroundImage: NetworkImage(userBasicInfo.profileImageUrl),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              "${userBasicInfo.firstName} ${userBasicInfo.lastName}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              userBasicInfo.email,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              userBasicInfo.phone,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              userBasicInfo.gender,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              userBasicInfo.dateOfBirth,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          userBasicInfo.userType != "Admin"? const SizedBox(
            height: 10,
          ) : Container(),
          userBasicInfo.userType != "Admin"? userBasicInfo.userType == "Moderator"? TextButton(
            onPressed: () {
              demoteUser(userBasicInfo);
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Demote',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ) : TextButton(
            onPressed: () {
              promoteUser(userBasicInfo);
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Promote',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ):Container(),
          userBasicInfo.userType != "Admin"? const SizedBox(
            height: 10,
          ) : Container(),
          userBasicInfo.userType != "Admin"? TextButton(
            onPressed: () {
              blockUser(userBasicInfo);

            },
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Block',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ) : Container(),
        ],
      ),
    );
  }

  Widget blockedUserLayout(UserBasicInfo userBasicInfo){
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
            child: userBasicInfo.profileImageUrl.isEmpty
                ? CircleAvatar(
              radius: 60,
              backgroundImage: userBasicInfo.gender == "Male"
                  ? const AssetImage(
                  'assets/male_profile_image.png')
                  : const AssetImage(
                'assets/female_profile_image.png',),
              // child: ClipOval(
              //   child: widget.userBasicInfo.gender == "Male"
              //       ? Image.asset(
              //           "assets/male_profile_image.png",
              //           fit: BoxFit.fill,
              //         )
              //       : Image.asset(
              //           "assets/female_profile_image.png",
              //           fit: BoxFit.fill,
              //         ),
              // ),
            )
                : CircleAvatar(
              radius: 60,
              // child: ClipOval(
              //   child: Image.network(
              //     widget.userBasicInfo.profileImageUrl,
              //     fit: BoxFit.fill,
              //   ),
              // ),
              backgroundImage: NetworkImage(userBasicInfo.profileImageUrl),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              "${userBasicInfo.firstName} ${userBasicInfo.lastName}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              userBasicInfo.email,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              userBasicInfo.phone,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              userBasicInfo.gender,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              userBasicInfo.dateOfBirth,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton(
            onPressed: () {
              unblockUser(userBasicInfo);
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Unblock',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> promoteUser(UserBasicInfo userBasicInfo) async{
    await FirebaseFirestore.instance.collection("Users").doc(userBasicInfo.userUid).collection("BasicInfo").doc(userBasicInfo.userUid).update({
      "userType" : "Moderator",
    });
    Fluttertoast.showToast(msg: "Promoted Successfully");
    getActiveUsersList();
  }

  Future<void> demoteUser(UserBasicInfo userBasicInfo) async{
    await FirebaseFirestore.instance.collection("Users").doc(userBasicInfo.userUid).collection("BasicInfo").doc(userBasicInfo.userUid).update({
      "userType" : "General",
    });
    Fluttertoast.showToast(msg: "Demoted Successfully");
    getActiveUsersList();

  }

  Future<void> blockUser(UserBasicInfo userBasicInfo) async{
    await FirebaseFirestore.instance.collection("BlockedUsersUid").doc(userBasicInfo.userUid).set({
      "userUid" : userBasicInfo.userUid,
      "email" : userBasicInfo.email,
      "phone" : userBasicInfo.phone,
    });
    await FirebaseFirestore.instance.collection("ActiveUsersUid").doc(userBasicInfo.userUid).delete();
    Fluttertoast.showToast(msg: "User Blocked");
    getBlockedUsersList();
    getActiveUsersList();
  }

  Future<void> unblockUser(UserBasicInfo userBasicInfo) async{

    await FirebaseFirestore.instance.collection("ActiveUsersUid").doc(userBasicInfo.userUid).set({
      "userUid" : userBasicInfo.userUid,
      "email" : userBasicInfo.email,
      "phone" : userBasicInfo.phone,
    });
    await FirebaseFirestore.instance.collection("BlockedUsersUid").doc(userBasicInfo.userUid).delete();
    Fluttertoast.showToast(msg: "User Unblocked");
    getBlockedUsersList();
    getActiveUsersList();

  }



}
