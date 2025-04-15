import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/community_utils/community_util.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../member_utils/approved_member_layout.dart';


class ApprovedMembersCommunityPage extends StatefulWidget {
  final DocumentReference databaseReference;
  final Community? community;
  final bool forCommunity;
  final UserBasicInfo viewerInfo;
  const ApprovedMembersCommunityPage({Key? key,this.community, required this.databaseReference, required this.viewerInfo, required this.forCommunity})
      : super(key: key);

  @override
  State<ApprovedMembersCommunityPage> createState() =>
      _ApprovedMembersCommunityPageState();
}

class _ApprovedMembersCommunityPageState
    extends State<ApprovedMembersCommunityPage> {
  List<UserBasicInfo> approvedMembersList = [];
  bool isLoading = true;
  Future<void> getApprovedMembersList() async {
    approvedMembersList.clear();
    await widget.databaseReference
        .collection("ApprovedMembers")
        .get()
        .then((snapshot) {
      for (int index = 0; index < snapshot.size; index++) {
        String uid = snapshot.docs[index].id;
        FirebaseFirestore.instance.collection("Users").doc(uid).collection("BasicInfo").doc(uid).get().then((value) {
          UserBasicInfo userBasicInfo = UserBasicInfo.fromJson(value.data()!);
          approvedMembersList.add(userBasicInfo);
          setState(() {});
        });
      }
    });

    isLoading = false;
    setState(() {});
  }
  bool isModerator = false;
  Future<void> getViewerInfo() async{
    widget.databaseReference.collection("Moderators").doc(widget.viewerInfo.userUid).snapshots().listen((event) {
      if(!mounted){
        return;
      }
      setState((){
        isModerator =  event.exists;
      });
    });
  }

  @override
  void initState() {
    getApprovedMembersList();
    getViewerInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      children: [
        NotificationListener<OverscrollNotification>(
          onNotification: (notification) => notification.metrics.axisDirection != AxisDirection.down,
          child: SizedBox(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : approvedMembersList.isEmpty
                ? const Center(
              child: Text("No members available"),
            )
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: approvedMembersList.length,
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return NotificationListener<OverscrollNotification>(
                  onNotification: (notification) => notification.metrics.axisDirection != AxisDirection.right,
                  child: ApprovedMemberLayout(
                    forCommunity: widget.forCommunity,
                    userBasicInfo: approvedMembersList[index],
                    onRefresh: () async{
                      getApprovedMembersList();
                    },
                    onPromote: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await widget.databaseReference
                            .collection("Moderators")
                            .doc(approvedMembersList[index].userUid)
                            .set({"userUid" : approvedMembersList[index].userUid});
                        Fluttertoast.showToast(
                            msg: "Member Promoted Successfully...");
                        setState((){
                          isLoading = false;
                        });
                      } on FirebaseException catch (e) {
                        Fluttertoast.showToast(
                            msg: "Something went wrong...");
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    onReject: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await widget.databaseReference
                            .collection("ApprovedMembers")
                            .doc(approvedMembersList[index].userUid)
                            .delete();
                        await FirebaseFirestore.instance.collection("Users").doc(approvedMembersList[index].userUid)
                            .collection("MyCommunities").doc(widget.community!.key).delete();
                        if(isModerator){
                          await widget.databaseReference
                              .collection("Moderators")
                              .doc(approvedMembersList[index].userUid)
                              .delete();
                        }
                        Fluttertoast.showToast(
                            msg: "Member Removed Successfully...");
                        getApprovedMembersList();
                      } on FirebaseException catch (e) {
                        Fluttertoast.showToast(
                            msg: "Something went wrong...");
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }, isModerator: isModerator, onDemote: () async{
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      await widget.databaseReference
                          .collection("Moderators")
                          .doc(approvedMembersList[index].userUid)
                          .delete();
                      Fluttertoast.showToast(
                          msg: "Member Demoted Successfully...");
                      setState((){
                        isLoading = false;
                      });
                    } on FirebaseException catch (e) {
                      Fluttertoast.showToast(
                          msg: "Something went wrong...");
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }, databaseReference: widget.databaseReference,
                    viewerInfo: widget.viewerInfo,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
