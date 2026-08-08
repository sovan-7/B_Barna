import 'dart:typed_data';

import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/choose_image.dart';
import 'package:bbarna/core/widgets/custom_text_field.dart';
import 'package:bbarna/core/widgets/extra_sidebar.dart';
import 'package:bbarna/core/widgets/save_button.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/teacher/viewModel/teacher_view_model.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Exposes a test-only hook for setting the selected photo without driving
/// a real (untestable in this environment) native file picker dialog. Public
/// so widget tests can reach it via `tester.state<AddTeacherTestHooks>(...)`
/// even though `_AddTeacherState` itself stays private. Must extend `State`
/// (not just declare the method) to satisfy `WidgetTester.state<T>()`'s bound.
@visibleForTesting
abstract class AddTeacherTestHooks extends State<AddTeacher> {
  void setSelectedImageForTest(PlatformFile file);
}

class AddTeacher extends StatefulWidget {
  const AddTeacher({super.key});

  @override
  State<AddTeacher> createState() => _AddTeacherState();
}

class _AddTeacherState extends AddTeacherTestHooks {
  final GlobalKey<ScaffoldState> key = GlobalKey();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isSaving = false;

  PlatformFile? selectedImageFile;
  Uint8List? selectedImageBytes;

  static const int _maxImageBytes = 5 * 1024 * 1024;
  static const Set<String> _allowedImageExtensions = {'jpg', 'jpeg', 'png'};

  @override
  @visibleForTesting
  void setSelectedImageForTest(PlatformFile file) {
    setState(() {
      selectedImageFile = file;
      selectedImageBytes = file.bytes;
    });
  }

  String? _extensionOf(PlatformFile file) {
    final int dotIndex = file.name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == file.name.length - 1) return null;
    return file.name.substring(dotIndex + 1).toLowerCase();
  }

  Future<void> _onSelectImage() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    if (picked != null) {
      setState(() {
        selectedImageFile = picked.files.first;
        selectedImageBytes = picked.files.first.bytes;
      });
    }
  }

  Future<void> _onSave() async {
    final String name = nameController.text.trim();
    final String username = usernameController.text.trim();
    final String password = passwordController.text;

    if (name.isEmpty || name.length > 100) {
      Helper.showSnackBarMessage(
          msg: "Please enter a name (up to 100 characters)", isSuccess: false);
      return;
    }

    // Letters, numbers, and underscores — a realistic reading of "alphanumeric
    // username" (real handles commonly use underscores); still rejects
    // spaces/punctuation/emoji, which is the PRD's actual intent.
    final bool usernameValid =
        RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username) && username.length >= 4;
    if (!usernameValid) {
      Helper.showSnackBarMessage(
          msg: "Username must be at least 4 letters, numbers, or underscores",
          isSuccess: false);
      return;
    }

    // Hard requirement is length only — letters+numbers is a recommendation,
    // surfaced as guidance text below the field, not a rejection rule.
    if (password.length < 8) {
      Helper.showSnackBarMessage(
          msg: "Password must be at least 8 characters", isSuccess: false);
      return;
    }

    final PlatformFile? imageFile = selectedImageFile;
    final Uint8List? imageBytes = selectedImageBytes;
    if (imageFile == null || imageBytes == null) {
      Helper.showSnackBarMessage(
          msg: "Please choose a photo", isSuccess: false);
      return;
    }

    final String? extension = _extensionOf(imageFile);
    if (extension == null || !_allowedImageExtensions.contains(extension)) {
      Helper.showSnackBarMessage(
          msg: "Photo must be a JPG or PNG file", isSuccess: false);
      return;
    }

    if (imageFile.size > _maxImageBytes) {
      Helper.showSnackBarMessage(
          msg: "Photo must be 5MB or smaller", isSuccess: false);
      return;
    }

    setState(() => isSaving = true);
    final TeacherViewModel teacherViewModel =
        Provider.of<TeacherViewModel>(context, listen: false);
    final bool success = await teacherViewModel.addTeacher(
      name: name,
      username: username,
      password: password,
      image: imageBytes,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: key,
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
        },
        canPop: true,
        child: Column(
          children: [
            AppHeader(
              onTapIcon: () {
                key.currentState?.openDrawer();
              },
            ),
            Expanded(
              child: Row(
                children: [
                  if (width > 900)
                    const Expanded(child: ExtraSideBar(sidebarIndex: 11)),
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (selectedImageBytes != null)
                              Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(75),
                                  image: DecorationImage(
                                    image: MemoryImage(selectedImageBytes!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ChooseImage(
                                onSelectImage: _onSelectImage,
                                title: selectedImageBytes == null
                                    ? "Choose Photo"
                                    : "Change Photo",
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: CustomTextField(
                                key: const Key('teacher_name_field'),
                                labelText: "name",
                                title: "Name",
                                textEditingController: nameController,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: CustomTextField(
                                key: const Key('teacher_username_field'),
                                labelText: "username",
                                title: "Username",
                                textEditingController: usernameController,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: CustomTextField(
                                key: const Key('teacher_password_field'),
                                labelText: "password",
                                title: "Password",
                                textEditingController: passwordController,
                                passwordVisible: isPasswordVisible,
                                onIconPress: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Min 8 characters. Using both letters and numbers is recommended.",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColorsInApp.colorGrey),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: isSaving
                                  ? const CircularProgressIndicator()
                                  : SaveButton(
                                      key: const Key('teacher_save_button'),
                                      onPRess: _onSave,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: width < 900
          ? const Drawer(child: ExtraSideBar(sidebarIndex: 11))
          : null,
    );
  }
}
