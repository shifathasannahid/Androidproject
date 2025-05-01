import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/community_utils/community_util.dart';
import 'package:eventqc/user_dashboard/community_page.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';

class MyCommunityHomePage extends StatefulWidget {
  final List<Community> communityList;
  final UserBasicInfo userBasicInfo;
  const MyCommunityHomePage({Key? key, required this.communityList, required this.userBasicInfo}) : super(key: key);

  @override
  State<MyCommunityHomePage> createState() => _MyCommunityHomePageState();
}

class _MyCommunityHomePageState extends State<MyCommunityHomePage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: MediaQuery.of(context).size.width,
      child:widget.communityList.isEmpty? const Center(child: Text("You're not in any communities", textAlign: TextAlign.center,),) : ListView.builder(
        itemCount: widget.communityList.length,
        scrollDirection: Axis.horizontal,
        physics: const ScrollPhysics(),
        itemBuilder: (context, index){
          return SizedBox(
            width: MediaQuery.of(context).size.width / 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityPage(community: widget.communityList[index], communityReference: FirebaseFirestore.instance.collection("Categories").doc(
                      widget.communityList[index].categoryKey).collection("Communities").doc(
                      widget.communityList[index].key), userBasicInfo: widget.userBasicInfo,)));
                },
                child: ListView(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(widget.communityList[index].coverImageUrl,),
                    ),
                    Text(widget.communityList[index].name, textAlign: TextAlign.center, style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),)
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
