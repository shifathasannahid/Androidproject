import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/login/login_page.dart';
import 'dart:io';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../community_utils/community_util.dart';

class MyProfilePageHome extends StatefulWidget {
  final UserBasicInfo userBasicInfo;
  final List<Community> myCommunityList;
  const MyProfilePageHome({Key? key, required this.userBasicInfo, required this.myCommunityList})
      : super(key: key);

  @override
  State<MyProfilePageHome> createState() => _MyProfilePageHomeState();
}

class _MyProfilePageHomeState extends State<MyProfilePageHome> {
  bool isLoading = false;

  @override
  void initState(){
    getRanking();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              imageProfile(),
              filePath == null
                  ? Container()
                  : const SizedBox(
                height: 20,
              ),
              filePath == null
                  ? Container()
                  : TextButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  uploadProfilePic();
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
                      'Upload Profile Image',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // InkWell(
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Stack(
              //         fit: StackFit.loose,
              //         alignment: Alignment.center,
              //         clipBehavior: Clip.hardEdge,
              //         children: [
              //           widget.userBasicInfo.profileImageUrl.isEmpty
              //               ? CircleAvatar(
              //                   radius: 80,
              //                   // backgroundImage: widget.userBasicInfo.gender == "Male"
              //                   //     ? const AssetImage(
              //                   //     'assets/male_profile_image.png')
              //                   //     : const AssetImage(
              //                   //     'assets/female_profile_image.png',),
              //                   child: ClipOval(
              //                     child: widget.userBasicInfo.gender == "Male"
              //                         ? Image.asset(
              //                             "assets/male_profile_image.png",
              //                             fit: BoxFit.fill,
              //                           )
              //                         : Image.asset(
              //                             "assets/female_profile_image.png",
              //                             fit: BoxFit.fill,
              //                           ),
              //                   ),
              //                 )
              //               : CircleAvatar(
              //                   radius: 80,
              //                   child: ClipOval(
              //                     child: Image.network(
              //                       widget.userBasicInfo.profileImageUrl,
              //                       fit: BoxFit.fill,
              //                     ),
              //                   ),
              //                   // backgroundImage: NetworkImage(widget.userBasicInfo.profileImageUrl),
              //                 ),
              //           const Positioned(
              //             right: 20,
              //             bottom: 0,
              //             child: Icon(
              //               Icons.camera_enhance_sharp,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  "${widget.userBasicInfo.firstName} ${widget.userBasicInfo.lastName}",
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
                  widget.userBasicInfo.email,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
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
                  widget.userBasicInfo.phone,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
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
                  widget.userBasicInfo.gender,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
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
                  "${getDate(widget.userBasicInfo.dateOfBirth, 0, false)} ${getDate(widget.userBasicInfo.dateOfBirth, 1, true)}, ${getDate(widget.userBasicInfo.dateOfBirth, 2, false)}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20,),

              rankingWidget(),



              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  showLogoutPopup();
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
                      'Logout',
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
          );
  }

  List<Map<String, dynamic>> communityRankMapList = [];

  Future<void> getRanking() async{
    communityRankMapList.clear();
    for(Community community in widget.myCommunityList){
      Map<String, dynamic> map = HashMap();
      map["community"] = community;
      FirebaseFirestore.instance.collection("Users").doc(widget.userBasicInfo.userUid).collection("QuizRank").doc(community.key).snapshots().listen((event) {
        if(!mounted){
          return;
        }
        if(event.exists){
          setState((){
            map["rankQuiz"] = event['rankQuiz'];
          });
        }
        else{
          setState((){
          map['rankQuiz'] = 0;});
        }
      });
      FirebaseFirestore.instance.collection("Users").doc(widget.userBasicInfo.userUid).collection("HelpPointRank").doc(community.key).snapshots().listen((event) {
        if(!mounted){
          return;
        }
        if(event.exists){
          setState((){map["rankHelpPoint"] = event['rankHelpPoint'];});
        }
        else{
          setState((){map['rankHelpPoint'] = 0;});
        }
      });

      setState((){communityRankMapList.add(map);});

    }
  }

  Widget rankingWidget(){
    return GridView.builder(
      itemCount: communityRankMapList.length,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (MediaQuery.of(context).orientation ==
              Orientation.portrait)
              ? 2
              : 3),
      itemBuilder: (context, index) => rankingLayout(communityRankMapList[index]),);
  }

  Widget rankingLayout(Map<String, dynamic> map) {
    return Card(
      color: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          // mainAxisSize: MainAxisSize.min,
          physics: const ScrollPhysics(),
          shrinkWrap: true,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  map["community"].coverImageUrl,
                ),
              ),
            ),
            Text(
              map["community"].name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "Quiz Rank: ${map["rankQuiz"]}",
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "Help Point Rank: ${map["rankHelpPoint"]}",
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<bool> showLogoutPopup() async {
    return await showDialog(
          //show confirm dialogue
          //the return value will be from "Yes" or "No" options
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text('Are you sure?'),
            content: const Text("Do you want to logout?"),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut().whenComplete(() =>
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage())));
                },
                //return true when click on "Yes"
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false; //if showDialouge had returned null, then return false
  }

  String getDate(String date, int position, bool isMonth) {
    if (isMonth) {
      int i = int.parse(date.split("-").toList()[position]);
      if (i == 1) {
        return "January";
      } else if (i == 2) {
        return "February";
      } else if (i == 3) {
        return "March";
      } else if (i == 4) {
        return "April";
      } else if (i == 5) {
        return "May";
      } else if (i == 6) {
        return "June";
      } else if (i == 7) {
        return "July";
      } else if (i == 8) {
        return "August";
      } else if (i == 9) {
        return "September";
      } else if (i == 10) {
        return "October";
      } else if (i == 11) {
        return "November";
      } else {
        return "December";
      }
    } else {
      return date.split("-").toList()[position];
    }
  }

  String? filePath;
  final dpPicker = ImagePicker();
  String profilePicUrl = "";
  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet()),
              );
            },
            child: filePath != null
                ? CircleAvatar(
                    radius: 80,
                    // backgroundImage: widget.userBasicInfo.gender == "Male"
                    //     ? const AssetImage(
                    //     'assets/male_profile_image.png')
                    //     : const AssetImage(
                    //     'assets/female_profile_image.png',),
              backgroundImage: Image.file(File(filePath!),).image,

              // child: ClipOval(
              //         child:Image.file(File(filePath!), fit: BoxFit.fill)),
                  )
                :  widget.userBasicInfo.profileImageUrl.isEmpty
                ? CircleAvatar(
                    radius: 80,
                    // backgroundImage: widget.userBasicInfo.gender == "Male"
                    //     ? const AssetImage(
                    //     'assets/male_profile_image.png')
                    //     : const AssetImage(
                    //     'assets/female_profile_image.png',),
                    child: ClipOval(
                      child: widget.userBasicInfo.gender == "Male"
                              ? Image.asset(
                                  "assets/male_profile_image.png",
                                  fit: BoxFit.fill,
                                )
                              : Image.asset(
                                  "assets/female_profile_image.png",
                                  fit: BoxFit.fill,
                                ),
                    ),
                  )
                : CircleAvatar(
                    radius: 80,
                    // child: ClipOval(
                    //   child: Image.network(
                    //     widget.userBasicInfo.profileImageUrl,
                    //     fit: BoxFit.fill,
                    //   ),
                    // ),
                    backgroundImage: NetworkImage(widget.userBasicInfo.profileImageUrl),
                  ),
          ),
          // CircleAvatar(
          //   radius: 80.0,
          //   backgroundImage: filePath=="null"? AssetImage("assets/user_avater_image.png") : Image.file(File(filePath),fit: BoxFit.cover).image,
          // ),

          // ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: ((builder) => bottomSheet()),
                );
              },
              child: const Icon(
                Icons.camera_alt,
                color: Colors.black54,
                size: 28.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: [
          const Text(
            "Choose photo from",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  takePhoto(ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt),
              ),
              IconButton(
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                },
                icon: const Icon(Icons.image),
              ),
            ],
          )
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await dpPicker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        filePath = pickedFile.path;
      } else {
        filePath = null;
      }
    });
  }

  Future uploadProfilePic() async {
    Fluttertoast.showToast(
        msg: "Please wait...", toastLength: Toast.LENGTH_LONG);

    UploadTask? uploadProfile() {
      try {
        final profileRef = FirebaseStorage.instance.ref(
            "Profile_Pictures/${widget.userBasicInfo.userUid}${baseName(filePath)}");

        return profileRef.putFile(File(filePath!));
      } on FirebaseException catch (e) {
        setState(() {
          isLoading = false;
          filePath = null;
        });
        return null;
      }
    }

    final snapshot = await uploadProfile()!.whenComplete(() {});
    profilePicUrl = await snapshot.ref.getDownloadURL().whenComplete(() {
      setState(() {
        widget.userBasicInfo.profileImageUrl = profilePicUrl;
      });
    });

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.userBasicInfo.userUid)
        .collection("BasicInfo")
        .doc(widget.userBasicInfo.userUid)
        .update({
      "profileImageUrl": profilePicUrl,
    }).whenComplete(() {
      setState(() {
        isLoading = false;
        filePath = null;
      });
    });
  }

  String baseName(path) {
    int pos = path.lastIndexOf("/") + 1;
    return path.substring(pos);
  }
}
