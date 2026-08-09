import 'dart:convert';

import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:bbarna/core/widgets/custom_text_field.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:bbarna/utils/size_config.dart';
import 'package:bbarna/resources/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoaderVisible = false;
  bool isPasswordVisible = false;
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppColorsInApp.colorLightBlue,
            height: SizeConfig.screenHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Container(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 25,
                                bottom: 50,
                              ),
                              margin: const EdgeInsets.only(
                                top: 80,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColorsInApp.colorWhite.withValues(alpha: .2),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "BBARNA ADMIN",
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                        color: AppColorsInApp.colorWhite),
                                  ),
                                  CustomTextField(
                                    labelText: "username",
                                    title: "",
                                    isBorderRadius: false,
                                    textEditingController: userNameController,
                                    focusNode: focusNode1,
                                  ),
                                  CustomTextField(
                                    labelText: "password",
                                    title: "",
                                    isBorderRadius: false,
                                    textEditingController: passwordController,
                                    passwordVisible: isPasswordVisible,
                                    focusNode: focusNode2,
                                    onIconPress: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ),
                                  if (!isLoaderVisible)
                                    InkWell(
                                      onTap: () async {
                                        if (userNameController
                                                .text.isNotEmpty &&
                                            passwordController
                                                .text.isNotEmpty) {
                                          setState(() {
                                            isLoaderVisible = true;
                                          });
                                          await loginAdmin(
                                                  userNameController.text,
                                                  passwordController.text)
                                              .then((value) {
                                            if (value != null) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Sidebar(
                                                          sidebarIndex: 0,
                                                        )),
                                              );
                                            } else {
                                              setState(() {
                                                isLoaderVisible = false;
                                              });
                                            }
                                          });
                                        } else {
                                          Helper.showSnackBarMessage(
                                              msg:
                                                  "Please fill the above field",
                                              isSuccess: false);
                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 350,
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.only(
                                          top: 25,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: AppColorsInApp.colorOrange,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Login",
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.0,
                                                  color: AppColorsInApp
                                                      .colorWhite),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20.0),
                                              child: Icon(
                                                Icons.lock,
                                                color:
                                                    AppColorsInApp.colorWhite,
                                                size: 20,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              )),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future loginAdmin(String mobileNo, String password) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference collectionReference = firestore.collection(teacher);
      // Teacher docs store a SHA-256 hash (see TeacherViewModel.addTeacher),
      // never the raw password — hash the typed password the same way
      // before comparing, or this query never matches.
      final String hashedPassword =
          sha256.convert(utf8.encode(password)).toString();
      QuerySnapshot querySnapshot = await collectionReference
          .where('username', isEqualTo: mobileNo)
          .where('password', isEqualTo: hashedPassword)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        sharedPreferences.setString("admin_id", querySnapshot.docs.first.id);
        sharedPreferences.setStringList(moduleAccessPrefsKey,
            List<String>.from(data['module_access'] ?? []));
        return querySnapshot.docs.first.id;
      } else {
        Helper.showSnackBarMessage(
            msg: "User name or password not matched", isSuccess: false);
        return null;
      }
    } catch (e) {
      Helper.showSnackBarMessage(msg: "Error while log in", isSuccess: false);
      return null;
    }
  }
}
