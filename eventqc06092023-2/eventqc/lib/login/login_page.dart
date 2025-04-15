import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:eventqc/login/forgot_password_page.dart';
import 'package:eventqc/login/privacy_policy_view.dart';
import 'package:eventqc/signup/signup_page.dart';
import 'package:eventqc/user_dashboard/user_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  bool updateAvailable = true;

  // @override
  // void initState() {
  //   super.initState();
  //   _initPackageInfo();
  // }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
    FirebaseFirestore.instance
        .collection("AppVersion")
        .doc("android")
        .snapshots()
        .listen((event) {
      if (event['version'] != _packageInfo.version ||
          event['buildNumber'] != _packageInfo.buildNumber) {
        if (!mounted) {
          return;
        }
        setState(() {
          updateAvailable = true;
        });

        showUpdateAppPopup();
      } else {
        setState(() {
          updateAvailable = false;
        });
        user = auth.currentUser;
        if (user != null && !updateAvailable) {
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const UserHomePage()));
          });
        }
      }
    });
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  bool showPassword = false;
  String emailString = "";
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool emailValidate = false;
  bool passwordValidate = false;

  bool isPhoneNumber = false;
  String countryCode = "+880";
  String userPhoneNumber = "";
  @override
  void initState() {
    _initPackageInfo();
    // user = auth.currentUser;
    // if (user != null && !updateAvailable) {
    //   Future.delayed(Duration.zero, () {
    //     Navigator.pushReplacement(context,
    //         MaterialPageRoute(builder: (context) => const UserHomePage()));
    //   });
    // }

    emailController.addListener(() {
      if(emailController.text.trim().isEmpty){
        setState((){
          isPhoneNumber = false;
          userPhoneNumber = "";
        });
      }
      else {
        try {
          int.parse(emailController.text.trim());
          setState(() {
            isPhoneNumber = true;
            userPhoneNumber = "$countryCode${emailController.text.trim()}";
          });
        }
        catch (e) {
          setState(() {
            isPhoneNumber = false;
            userPhoneNumber = "";
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: updateAvailable
          ? InkWell(
              onTap: () {
                _launchURL();
              },
              child: Center(
                child: Container(
                    width: 250,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.blue,
                    ),
                    child: const Center(
                      child: Text(
                        "Update app",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    )),
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                color: Color(0xff46b5be),
              ),
              child: ListView(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Image.asset(
                    'assets/login_page_logo.png',
                    height: 300,
                    width: 300,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: RichText(
                      text: const TextSpan(children: [
                        TextSpan(
                          text: "Welcome to ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: "EventQc",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: isPhoneNumber?  Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.account_circle,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 120,
                              child: CountryCodePicker(
                                favorite: const ["BD"],
                                initialSelection: "BD",
                                alignLeft: true,

                                onChanged: (countryCode){
                                  if(countryCode.dialCode != null) {
                                    this.countryCode = countryCode.dialCode!;
                                  }
                                },
                              ),
                            )
                          ],
                        ) : const Icon(
                          Icons.account_circle,
                          color: Colors.black,
                        ),
                        // prefix: isPhoneNumber? SizedBox(
                        //   width: 120,
                        //   child: CountryCodePicker(
                        //     favorite: const ["BD"],
                        //     initialSelection: "BD",
                        //     alignLeft: true,
                        //
                        //     onChanged: (countryCode){
                        //       if(countryCode.dialCode != null) {
                        //         this.countryCode = countryCode.dialCode!;
                        //       }
                        //     },
                        //   ),
                        // ) :null,
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Color(0xff63d2db),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Color(0xff63d2db),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Color(0xff63d2db),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Color(0xff63d2db),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        hintStyle: const TextStyle(color: Colors.black),
                        hintText: "Email / Phone",
                        errorText:
                            emailValidate ? "Enter a valid email/number" : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordController,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Color(0xff63d2db),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Color(0xff63d2db),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Color(0xff63d2db),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Color(0xff63d2db),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        hintStyle: const TextStyle(color: Colors.black),
                        hintText: "Password",
                        errorText:
                            passwordValidate ? "Enter a valid password" : null,
                        suffixIcon: showPassword
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    showPassword = false;
                                  });
                                },
                                child: const Icon(
                                  Icons.remove_red_eye_outlined,
                                  color: Colors.black,
                                ))
                            : InkWell(
                                onTap: () {
                                  setState(() {
                                    showPassword = true;
                                  });
                                },
                                child: const Icon(
                                  Icons.remove_red_eye_sharp,
                                  color: Colors.black,
                                )),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordPage()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 20, 15),
                      child: RichText(
                        textAlign: TextAlign.end,
                        text: const TextSpan(
                          text: "Forgot password?",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      if (emailController.text.trim().isEmpty) {
                        setState(() {
                          emailValidate = true;
                        });
                        return;
                      } else if (!emailController.text.trim().contains("@") ||
                          !emailController.text.trim().contains(".")) {
                        if (isPhoneNumber) {
                          await FirebaseFirestore.instance
                              .collection("ActiveUsersUid")
                              .where("phone",
                                  isEqualTo: userPhoneNumber)
                              .limit(1)
                              .get()
                              .then((value) {
                            if (value.size != 0) {
                              setState(() {
                                emailString = value.docs[0]['email'];
                                emailValidate = false;
                              });
                            } else {
                              setState(() {
                                emailValidate = true;
                                emailString = "";
                              });
                              return;
                            }
                          });
                        } else {
                          setState(() {
                            emailValidate = true;
                            emailString = "";
                          });
                          return;
                        }
                      } else if (emailController.text.trim().contains("@") &&
                          emailController.text.trim().contains(".")) {
                        await FirebaseFirestore.instance
                            .collection("ActiveUsersUid")
                            .where("email",
                                isEqualTo: emailController.text.trim())
                            .limit(1)
                            .get()
                            .then((value) {
                          if (value.size != 0) {
                            setState(() {
                              emailString = value.docs[0]['email'];
                              emailValidate = false;
                            });
                          } else {
                            setState(() {
                              emailValidate = true;
                              emailString = "";
                            });
                            return;
                          }
                        });
                      }

                      if (passwordController.text.isEmpty) {
                        setState(() {
                          passwordValidate = true;
                        });
                        return;
                      } else {
                        setState(() {
                          passwordValidate = false;
                        });
                      }

                      if (emailString.isNotEmpty) {
                        try {
                          auth
                              .signInWithEmailAndPassword(
                                  email: emailString,
                                  password: passwordController.text)
                              .then((UserCredential userCredential) {
                            if (userCredential.user != null) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const UserHomePage()));
                            } else {
                              Fluttertoast.showToast(msg: "Login failed");
                            }
                          }).catchError((onError) {
                            Fluttertoast.showToast(msg: "Login Failed");
                          });
                        } on FirebaseException catch (e) {
                          Fluttertoast.showToast(msg: "Login failed");
                        }
                      }
                    },
                    child: Center(
                      child: Container(
                          width: 250,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Text(
                              "SIGN IN",
                              style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 2,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                      RichText(
                        text: const TextSpan(
                          text: "   OR   ",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 2,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupPage()));
                    },
                    child: Center(
                      child: Container(
                          width: 250,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Text(
                              "CREATE NEW ACCOUNT",
                              style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text:
                                  "By creating an account you will be agreed with our ",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text: "Terms & Privacy Policy ",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoadPrivacyPage()));
                              },
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<bool> showUpdateAppPopup() async {
    return await showDialog(
          //show confirm dialogue
          //the return value will be from "Yes" or "No" options
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text('New version available!'),
            content: const Text(
                "There is new version of this app. Update the app to latest version."),
            actions: [
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                //return false when click on "NO"
                child: const Text('cancel'),
              ),
              ElevatedButton(
                onPressed: () => _launchURL(),
                //return true when click on "Yes"
                child: const Text('Update'),
              ),
            ],
          ),
        ) ??
        false; //if showDialouge had returned null, then return false
  }

  _launchURL() async {
    if (await canLaunchUrl(Uri.parse(
        "https://play.google.com/store/apps/details?id=${_packageInfo.packageName}"))) {
      await launchUrl(
          Uri.parse(
              "https://play.google.com/store/apps/details?id=${_packageInfo.packageName}"),
          mode: LaunchMode.externalApplication);
    } else {
      // throw 'Could not launch ${widget.liveLinkUrl}';
      Fluttertoast.showToast(msg: "Something went wrong");
      // Navigator.pop(context);
    }
  }
}
