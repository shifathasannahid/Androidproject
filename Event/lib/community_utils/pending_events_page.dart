import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/event_utils/event_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../event_utils/pending_event_layout.dart';

class PendingEventsCommunityPage extends StatefulWidget {
  final DocumentReference communityReference;

  const PendingEventsCommunityPage({Key? key, required this.communityReference})
      : super(key: key);

  @override
  State<PendingEventsCommunityPage> createState() =>
      _PendingEventsCommunityPageState();
}

class _PendingEventsCommunityPageState
    extends State<PendingEventsCommunityPage> {
  List<Event> pendingEventsList = [];
  bool isLoading = true;
  Future<void> getPendingEventsList() async {
    pendingEventsList.clear();
    await widget.communityReference
        .collection("PendingEvents")
        .get()
        .then((snapshot) {
      for (int index = 0; index < snapshot.size; index++) {
        Event event = Event.fromJson(snapshot.docs[index].data());
        pendingEventsList.add(event);
        setState(() {});
      }
    });

    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getPendingEventsList();
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
                : pendingEventsList.isEmpty
                    ? const Center(
                        child: Text("No pending events available"),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pendingEventsList.length,
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return NotificationListener<OverscrollNotification>(
                            onNotification: (notification) => notification.metrics.axisDirection != AxisDirection.right,
                            child: PendingEventLayout(
                              event: pendingEventsList[index],
                              onRefresh: () async{
                                getPendingEventsList();
                              },
                              onApprove: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  await widget.communityReference
                                      .collection("ApprovedEvents")
                                      .doc(pendingEventsList[index].key)
                                      .set(pendingEventsList[index].toJson());
                                  await widget.communityReference
                                      .collection("PendingEvents")
                                      .doc(pendingEventsList[index].key)
                                      .delete();
                                  Fluttertoast.showToast(
                                      msg: "Event Approved Successfully...");
                                  getPendingEventsList();
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
                                  await widget.communityReference
                                      .collection("PendingEvents")
                                      .doc(pendingEventsList[index].key)
                                      .delete();
                                  Fluttertoast.showToast(
                                      msg: "Event Rejected Successfully...");
                                  getPendingEventsList();
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
