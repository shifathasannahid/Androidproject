import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/community_utils/community_util.dart';
import 'package:eventqc/community_utils/discussion_layout.dart';
import 'package:eventqc/community_utils/discussion_util.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ntp/ntp.dart';

class DiscussionsCommunityPage extends StatefulWidget {
  final Community community;
  final DocumentReference communityReference;
  final UserBasicInfo viewerBasicInfo;
  final bool isModerator;
  final ScrollController scrollController;
  const DiscussionsCommunityPage(
      {Key? key,
      required this.community,
      required this.viewerBasicInfo,
      required this.communityReference,
      required this.isModerator,
      required this.scrollController,})
      : super(key: key);

  @override
  State<DiscussionsCommunityPage> createState() =>
      _DiscussionsCommunityPageState();
}

class _DiscussionsCommunityPageState extends State<DiscussionsCommunityPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool titleValidate = false;
  bool descriptionValidate = false;
  bool isProcessing = false;
  bool isAdmin = false;

  List<DocumentSnapshot> posts = []; // stores fetched products
  bool isLoading = false; // track if products fetching
  bool hasMore = true; // flag for more products available or not
  int documentLimit = 10; // documents to be fetched per request
  DocumentSnapshot?
      lastDocument; // flag for last document from where next 10 records to be fetched
  // ScrollController scrollController =
  //     ScrollController(); // listener for listview scrolling

  List<Discussion> discussionsList = [];
  getPosts() async {
    if (!hasMore) {
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      await widget.communityReference
          .collection('Discussions')
          .where("isSolved", isEqualTo: "false")
          .orderBy('timeStamp', descending: true)
          .limit(documentLimit)
          .get().then((value) {
        for(int i = 0; i< value.size; i++){
          if(!mounted){
            return;
          }
          setState((){
            discussionsList.add(Discussion.fromJson(value.docs[i].data()));
          });
        }
      });
      querySnapshot = await widget.communityReference
          .collection('Discussions')
          .where("isSolved", isEqualTo: "false")
          .orderBy('timeStamp', descending: true)
          .limit(documentLimit)
          .get();
    } else {
      await widget.communityReference
          .collection('Discussions')
          .where("isSolved", isEqualTo: "false")
          .orderBy('timeStamp', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(documentLimit)
          .get().then((value) {
            for(int i = 0; i< value.size; i++){
              if(!mounted){
                return;
              }
              setState((){
                discussionsList.add(Discussion.fromJson(value.docs[i].data()));
              });
            }
      });
      querySnapshot = await widget.communityReference
          .collection('Discussions')
          .where("isSolved", isEqualTo: "false")
          .orderBy('timeStamp', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(documentLimit)
          .get();
    }
    if (querySnapshot.size < documentLimit) {
      hasMore = false;
    }
    if(querySnapshot.size != 0){

      lastDocument = querySnapshot.docs[querySnapshot.size - 1];

    }
    posts.addAll(querySnapshot.docs);
    if(!mounted){
      return;
    }
    setState(() {
      discussionsList.sort((a, b) {
        DateTime dateA = DateTime(int.parse(a.publishDate.split("-").toList()[2]),int.parse(a.publishDate.split("-").toList()[1]),int.parse(a.publishDate.split("-").toList()[0]), int.parse(a.publishTime.split(":").toList()[0]), int.parse(a.publishTime.split(":").toList()[1]));
        DateTime dateB = DateTime(int.parse(b.publishDate.split("-").toList()[2]),int.parse(b.publishDate.split("-").toList()[1]),int.parse(b.publishDate.split("-").toList()[0]), int.parse(b.publishTime.split(":").toList()[0]), int.parse(b.publishTime.split(":").toList()[1]));
        return dateB.compareTo(dateA);
      });
      isLoading = false;
    });
  }

  List<Discussion> pinnedDiscussionsList = [];

  Future<void> getPinnedPost() async{
    pinnedDiscussionsList.clear();
    widget.communityReference
        .collection('Discussions')
        .where("isPined", isEqualTo: "true")
        .orderBy('timeStamp', descending: true)
        .snapshots().listen((value) {
      pinnedDiscussionsList.clear();

      for(int i = 0; i< value.size; i++){
        if(!mounted){
          return;
        }
        setState((){
          pinnedDiscussionsList.add(Discussion.fromJson(value.docs[i].data()));
        });
      }
    });
  }

  List<Discussion> solvedDiscussionsList = [];

  Future<void> getSolvedPost() async{
    solvedDiscussionsList.clear();
    widget.communityReference
        .collection('Discussions')
        .where("isSolved", isEqualTo: "true")
        .orderBy('timeStamp', descending: true)
    .snapshots().listen((value) {
      solvedDiscussionsList.clear();

      for(int i = 0; i< value.size; i++){
        if(!mounted){
          return;
        }
        setState((){
          solvedDiscussionsList.add(Discussion.fromJson(value.docs[i].data()));
        });
      }
    });
  }
  Future<void> getIsAdmin() async{
    setState((){
      isAdmin = widget.viewerBasicInfo.userType == "Admin" || widget.viewerBasicInfo.userType == "Moderator";
    });
  }

  @override
  void initState() {
    widget.scrollController.addListener(() {
      if(!mounted){
        return;
      }
      double maxScroll = widget.scrollController.position.maxScrollExtent;
      double currentScroll = widget.scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.10;
      if (maxScroll - currentScroll <= delta) {
        getPosts();
      }
      if(currentScroll <=0){
        setState((){
          lastDocument = null;
          hasMore = true;
          discussionsList.clear();
          Fluttertoast.showToast(msg: "Refreshing");
          getPosts();
        });
      }
    });

    getIsAdmin();
    getPinnedPost();
    getPosts();
    getSolvedPost();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Discuss about your problem",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: titleController,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Problem title...",
                    errorText:
                        titleValidate ? "This field can't be empty" : null,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: descriptionController,
                  maxLines: null,
                  minLines: 5,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: "Describe your problem here...",
                    errorText: descriptionValidate
                        ? " This field can't be empty"
                        : null,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (!isProcessing) {
                      if (titleController.text.trim().isEmpty) {
                        setState(() {
                          titleValidate = true;
                        });
                      } else if (descriptionController.text.trim().isEmpty) {
                        setState(() {
                          titleValidate = false;
                          descriptionValidate = true;
                        });
                      } else {
                        setState(() {
                          titleValidate = false;
                          descriptionValidate = false;
                          isProcessing = true;
                        });
                        FocusScope.of(context).unfocus();
                        postProblem();
                      }
                    } else {
                      Fluttertoast.showToast(msg: "Please wait");
                    }
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
                        'Post problem',
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
          ),
        ),
        ListView.builder(
          itemCount: pinnedDiscussionsList.length,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemBuilder: (context, index) => DiscussionLayout(discussion: pinnedDiscussionsList[index], discussionReference: widget.communityReference.collection("Discussions").doc(pinnedDiscussionsList[index].key), isModerator: widget.isModerator, isAdmin: isAdmin, viewerUid: widget.viewerBasicInfo.userUid,),
        ),
        ListView.builder(
          itemCount: discussionsList.length,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemBuilder: (context, index) => DiscussionLayout(discussion: discussionsList[index], discussionReference: widget.communityReference.collection("Discussions").doc(discussionsList[index].key), isModerator: widget.isModerator, isAdmin: isAdmin, viewerUid: widget.viewerBasicInfo.userUid,),
        ),
        isLoading? const Center(child: CircularProgressIndicator(),) : Container(),
        ListView.builder(
          itemCount: solvedDiscussionsList.length,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemBuilder: (context, index) => DiscussionLayout(discussion: solvedDiscussionsList[index], discussionReference: widget.communityReference.collection("Discussions").doc(solvedDiscussionsList[index].key), isModerator: widget.isModerator, isAdmin: isAdmin, viewerUid: widget.viewerBasicInfo.userUid,),
        ),
      ],
    );
  }

  Future<void> postProblem() async {
    String key = widget.communityReference.collection("Discussions").doc().id;

    DateTime now = DateTime.now();
    final int offset = await NTP.getNtpOffset();
    DateTime today = now.add(Duration(milliseconds: offset));

    String publishTime = "${today.hour}:${today.minute}";
    String publishDate = "${today.day}-${today.month}-${today.year}";
    String problemTitle = titleController.text.trim();
    String problemDescription = descriptionController.text.trim();

    Discussion discussion = Discussion(
      key,
      widget.viewerBasicInfo.userUid,
      publishDate,
      publishTime,
      problemTitle,
      problemDescription,
      "false",
      "false",
      widget.community.categoryKey,
      widget.community.key,
      today.toString(),
    );
    try {
      await widget.communityReference
          .collection("Discussions")
          .doc(key)
          .set(discussion.toJson())
          .whenComplete(() {
        setState(() {
          isProcessing = false;
          titleController.text = "";
          descriptionController.text = "";
        });
        Fluttertoast.showToast(msg: "Problem published successfully");
      });
    } on FirebaseException catch (e) {
      setState(() {
        isProcessing = false;
        titleController.text = "";
        descriptionController.text = "";
      });
      Fluttertoast.showToast(msg: "Something went wrong\nPlease try again");
    }
  }
}
