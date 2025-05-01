import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:eventqc/community_utils/category_model_util.dart';
import 'package:eventqc/community_utils/community_util.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as system_paths;

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({Key? key}) : super(key: key);

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String communityName = "";
  String categoryName = "";
  String description = "";
  String timeStamp = "";
  String createDate = "";

  XFile? _pickedFile;
  CroppedFile? _croppedFile;

  bool nameValidate = false;
  bool categoryValidate = false;
  bool descriptionValidate = false;

  String imageUrl = '';
  bool isProcessing = true;
  bool hideDropdown = false;

  List<CategoryModel> categoryList = [];
  List<CategoryModel> categoryFilterList = [];
  CategoryModel? selectedCategory;

  Future<void> getCategoryList() async {
    categoryList.clear();
    await FirebaseFirestore.instance
        .collection("Categories")
        .get()
        .then((snapshot) {
      for (int index = 0; index < snapshot.size; index++) {
        CategoryModel categoryModel =
            CategoryModel.fromJson(snapshot.docs[index].data());
        categoryList.add(categoryModel);
      }
    });
    setState(() {
      isProcessing = false;
    });
  }

  Future<void> filterCategoryByName(String? string) async {
    if (string == null || string.isEmpty) {
      categoryFilterList = [];
    } else {
      categoryFilterList = categoryList
          .where((element) => element.name.startsWith(string))
          .toList();
    }
    setState(() {
      hideDropdown = false;
    });
  }

  @override
  void initState() {
    getCategoryList();
    categoryController.addListener(() {
      filterCategoryByName(categoryController.text.trim().toUpperCase());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new community"),
        centerTitle: true,
      ),
      body: isProcessing
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width) - 20,
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
                        hintText: "Enter community name",
                        errorText:
                            nameValidate ? "This field can't be empty" : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width) - 20,
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: categoryController,
                      decoration: InputDecoration(
                        labelText: "Category",
                        hintText: "Enter category name",
                        errorText: categoryValidate
                            ? "This field can't be empty"
                            : null,
                      ),
                    ),
                  ),
                ),
                categoryFilterList.isEmpty || hideDropdown == true
                    ? Container()
                    : SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Card(
                            elevation: 15,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: categoryFilterList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        categoryController.text =
                                            categoryFilterList[index].name;
                                        hideDropdown = true;
                                        FocusScope.of(context).unfocus();
                                        setState((){

                                        });
                                      },
                                      child: ListTile(
                                        subtitle: Text(
                                          categoryFilterList[index].name,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 1,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width) - 20,
                    child: TextFormField(
                      keyboardType: TextInputType.multiline,
                      controller: descriptionController,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: "Description",
                        hintText: "Describe the community",
                        errorText: descriptionValidate
                            ? "This field can't be empty"
                            : null,
                      ),
                    ),
                  ),
                ),


                const SizedBox(
                  height: 20,
                ),


                // Expanded(flex: 1,child: Container(child: _imageSelector()),),

                _imageSelector(),
                const SizedBox(
                  height: 20,
                ),

                TextButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      nameValidate = true;
                      setState(() {});
                    } else if (categoryController.text.trim().isEmpty) {
                      categoryValidate = true;
                      nameValidate = false;
                      setState(() {});
                    } else if (descriptionController.text.trim().isEmpty) {
                      nameValidate = false;
                      categoryValidate = false;
                      descriptionValidate = true;
                      setState(() {});
                    } else if (_pickedFile == null) {
                      nameValidate = false;
                      categoryValidate = false;
                      descriptionValidate = false;
                      setState(() {});
                      Fluttertoast.showToast(
                          msg: "Upload a cover image");
                    } else {
                      DateTime now = DateTime.now();
                      communityName = nameController.text.trim();
                      categoryName =
                          categoryController.text.trim().toUpperCase();
                      description = descriptionController.text.trim();
                      isProcessing = true;
                      createDate = "${now.day}-${now.month}-${now.year}";
                      timeStamp =
                          "${now.hour}${now.minute}${now.second}${now.day}${now.month}${now.year}";
                      setState(() {});
                      await createCategory();
                      if (selectedCategory == null) {
                        Fluttertoast.showToast(
                            msg:
                                "Something went wrong...\nPlease try again...");
                        setState(() {
                          isProcessing = false;
                        });
                      } else {
                        if (_croppedFile != null) {
                          uploadDataFromCropped();
                        } else {
                          uploadDataFromPicked();
                        }
                      }
                      // uploadData();
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
                        'Create',
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

  Future<void> createCategory() async {
    if (categoryList
        .where((element) => element.name == categoryName)
        .toList()
        .isEmpty) {
      String key = FirebaseFirestore.instance.collection("Categories").doc().id;
      CategoryModel categoryModel = CategoryModel(key, categoryName);
      await FirebaseFirestore.instance
          .collection("Categories")
          .doc(key)
          .set(categoryModel.toJson())
          .whenComplete(() => selectedCategory = categoryModel);
    } else {
      selectedCategory = categoryList
          .where((element) => element.name == categoryName)
          .toList()[0];
    }
    setState(() {});
  }

  String baseName(path) {
    int pos = path.lastIndexOf("/") + 1;
    return path.substring(pos);
  }

  Future<void> uploadDataFromPicked() async {
    Fluttertoast.showToast(
        msg: "Please wait...", toastLength: Toast.LENGTH_LONG);
    UploadTask? uploadImage() {
      try {
        final imageRef = FirebaseStorage.instance.ref(
            "Image/$categoryName/$communityName/$timeStamp${baseName(_pickedFile!.path)}");

        return imageRef.putFile(File(_pickedFile!.path));
      } on FirebaseException catch (e) {
        setState(() {
          isProcessing = false;
        });
        return null;
      }
    }

    final snapshot = await uploadImage()!.whenComplete(() {});
    imageUrl = await snapshot.ref.getDownloadURL().whenComplete(() {
      setState(() {});
    });
    addCommunityInDatabase();
  }

  Future<void> uploadDataFromCropped() async {
    Fluttertoast.showToast(
        msg: "Please wait...", toastLength: Toast.LENGTH_LONG);
    Uint8List bytes = await _croppedFile!.readAsBytes();
    final appDir = await system_paths.getTemporaryDirectory();
    File file = File('${appDir.path}/$timeStamp.jpg');
    await file.writeAsBytes(bytes);

    UploadTask? uploadImage() {
      try {
        final imageRef = FirebaseStorage.instance.ref(
            "Image/$categoryName/$communityName/$timeStamp${baseName(_pickedFile!.path)}");

        return imageRef.putFile(file);
      } on FirebaseException catch (e) {
        setState(() {
          isProcessing = false;
        });
        return null;
      }
    }

    final snapshot = await uploadImage()!.whenComplete(() {});
    imageUrl = await snapshot.ref.getDownloadURL().whenComplete(() {
      setState(() {});
    });
    addCommunityInDatabase();
  }

  Future<void> addCommunityInDatabase() async {
    String key = FirebaseFirestore.instance
        .collection("Categories")
        .doc(selectedCategory!.key)
        .collection("Communities").doc().id;
    String creationDate =
        "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
    Community community = Community(
      key,
      selectedCategory!.key,
      communityName,
      creationDate,
      selectedCategory!.name,
      imageUrl,
      description,
    );
    await FirebaseFirestore.instance
        .collection("Categories")
        .doc(selectedCategory!.key)
        .collection("Communities")
        .doc(key)
        .set(community.toJson())
        .whenComplete(() {

      Fluttertoast.showToast(msg: "Community added successfully...");
      Navigator.pop(context);
    });
  }

  Widget _imageSelector() {
    if (_croppedFile != null || _pickedFile != null) {
      return _imageCard();
    } else {
      return _uploaderCard();
    }
  }

  Widget _imageCard() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 4.0,
            child: _image(),
          ),
          const SizedBox(height: 24.0),
          _menu(),
        ],
      ),
    );
  }

  Widget _image() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: kIsWeb
            ? AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  path,
                  fit: BoxFit.fill,
                ),
              )
            : AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(
                  File(path),
                  fit: BoxFit.fill,
                )),
      );
    } else if (_pickedFile != null) {
      final path = _pickedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: kIsWeb
            ? AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  path,
                  fit: BoxFit.fill,
                ))
            : AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(
                  File(path),
                  fit: BoxFit.fill,
                )),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _menu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "delete",
          onPressed: () {
            _clear();
          },
          backgroundColor: Colors.black,
          tooltip: 'Delete',
          child: const Icon(Icons.delete),
        ),
        // if (_croppedFile == null)
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: FloatingActionButton(
            heroTag: "edit",
            onPressed: () {
              _cropImage();
            },
            backgroundColor: Colors.black,
            tooltip: 'Edit',
            child: const Icon(Icons.edit),
          ),
        )
      ],
    );
  }

  Widget _uploaderCard() {
    return Center(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SizedBox(
          width: kIsWeb ? 380.0 : 320.0,
          height: 300.0,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DottedBorder(
                    radius: const Radius.circular(12.0),
                    borderType: BorderType.RRect,
                    dashPattern: const [8, 4],
                    color: Theme.of(context).highlightColor.withOpacity(0.4),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            color: Theme.of(context).highlightColor,
                            size: 80.0,
                          ),
                          const SizedBox(height: 24.0),
                          Text(
                            'Upload an cover image to continue',
                            style: kIsWeb
                                ? Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                        color: Theme.of(context).highlightColor)
                                : Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                        color:
                                            Theme.of(context).highlightColor),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton(
                  onPressed: () {
                    _uploadImage();
                  },
                  child: const Text('Upload'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        compressQuality: 100,
        // uiSettings: [
        //   AndroidUiSettings(
        //       toolbarTitle: 'Cropper',
        //       toolbarColor: Colors.deepOrange,
        //       toolbarWidgetColor: Colors.white,
        //       initAspectRatio: CropAspectRatioPreset.ratio16x9,
        //       lockAspectRatio: true),
        //   IOSUiSettings(
        //     title: 'Cropper',
        //   ),
        // ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
      _cropImage();
    }
  }

  void _clear() {
    setState(() {
      _pickedFile = null;
      _croppedFile = null;
    });
  }
}
