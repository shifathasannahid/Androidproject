import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/event_utils/event_util.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../member_utils/pending_member_layout.dart';
import 'community_util.dart';


class PendingMembersCommunityPage extends StatefulWidget {
  final DocumentReference databaseReference;
  final bool forCommunity;
  final int? totalRegistration;
  final int? maximumRegistration;
  final Community? community;
  final Event? event;

  const PendingMembersCommunityPage({Key? key, required this.databaseReference, required this.forCommunity, this.totalRegistration, this.maximumRegistration, this.community, this.event})
      : super(key: key);

  @override
  State<PendingMembersCommunityPage> createState() =>
      _PendingMembersCommunityPageState();
}

class _PendingMembersCommunityPageState
    extends State<PendingMembersCommunityPage> {
  List<UserBasicInfo> pendingMembersList = [];
  bool isLoading = true;
  Future<void> getPendingMembersList() async {
    pendingMembersList.clear();
    await widget.databaseReference
        .collection("PendingMembers")
        .get()
        .then((snapshot) {
      for (int index = 0; index < snapshot.size; index++) {
        String uid = snapshot.docs[index].id;
        FirebaseFirestore.instance.collection("Users").doc(uid).collection("BasicInfo").doc(uid).get().then((value) {
          UserBasicInfo userBasicInfo = UserBasicInfo.fromJson(value.data()!);
          pendingMembersList.add(userBasicInfo);
          setState(() {});
        });
      }
    });

    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getPendingMembersList();
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
                : pendingMembersList.isEmpty
                ? const Center(
              child: Text("No pending members available"),
            )
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pendingMembersList.length,
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return NotificationListener<OverscrollNotification>(
                  onNotification: (notification) => notification.metrics.axisDirection != AxisDirection.right,
                  child: PendingMemberLayout(
                    forCommunity: widget.forCommunity,
                    userBasicInfo: pendingMembersList[index],
                    onRefresh: () async{
                      getPendingMembersList();
                    },
                    onApprove: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        if(widget.forCommunity) {
                          await widget.databaseReference
                              .collection("ApprovedMembers")
                              .doc(pendingMembersList[index].userUid)
                              .set(
                              {"userUid": pendingMembersList[index].userUid});
                          await widget.databaseReference
                              .collection("PendingMembers")
                              .doc(pendingMembersList[index].userUid)
                              .delete();

                          await FirebaseFirestore.instance.collection("Users").doc(pendingMembersList[index].userUid)
                          .collection("MyCommunities").doc(widget.community!.key).set(widget.community!.toJson());

                          Fluttertoast.showToast(
                              msg: "Member Approved Successfully...");

                        }
                        else{
                          if(widget.totalRegistration! < widget.maximumRegistration!){
                            await widget.databaseReference
                                .collection("ApprovedMembers")
                                .doc(pendingMembersList[index].userUid)
                                .set(
                                {"userUid": pendingMembersList[index].userUid});
                            await widget.databaseReference
                                .collection("PendingMembers")
                                .doc(pendingMembersList[index].userUid)
                                .delete();
                            await widget.databaseReference.update({
                              "totalRegistration" : (widget.totalRegistration! + 1).toString(),
                            });
                            await FirebaseFirestore.instance.collection("Users").doc(pendingMembersList[index].userUid)
                            .collection("JoinedEvents").doc(widget.event!.key).set(widget.event!.toJson());
                            Fluttertoast.showToast(
                                msg: "Member Approved Successfully...");
                          }
                          else{
                            Fluttertoast.showToast(msg: "No seats available");
                          }
                        }
                        getPendingMembersList();
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
                            .collection("PendingMembers")
                            .doc(pendingMembersList[index].userUid)
                            .delete();
                        Fluttertoast.showToast(
                            msg: "Member Rejected Successfully...");
                        getPendingMembersList();
                      } on FirebaseException catch (e) {
                        Fluttertoast.showToast(
                            msg: "Something went wrong...");
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
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
