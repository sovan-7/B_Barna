import 'dart:typed_data';

import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/custom_text_field.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/core/widgets/save_button.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/teacher/model/teacher_model.dart';
import 'package:bbarna/teacher/viewModel/teacher_view_model.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Exposes a test-only hook for setting the selected photo without driving
/// a real (untestable in this environment) native file picker dialog — same
/// rationale as [AddTeacherTestHooks] in add_teacher.dart.
@visibleForTesting
abstract class EditTeacherTestHooks extends State<EditTeacher> {
  void setSelectedImageForTest(PlatformFile file);
}

class EditTeacher extends StatefulWidget {
  final TeacherModel teacherData;
  const EditTeacher({required this.teacherData, super.key});

  @override
  State<EditTeacher> createState() => _EditTeacherState();
}

class _EditTeacherState extends EditTeacherTestHooks {
  final GlobalKey<ScaffoldState> key = GlobalKey();

  late final TextEditingController nameController;
  late final TextEditingController usernameController;
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isSaving = false;

  PlatformFile? selectedImageFile;
  Uint8List? selectedImageBytes;

  late final Set<String> selectedModules;
  late String selectedRole;

  static const int _maxImageBytes = 5 * 1024 * 1024;
  static const Set<String> _allowedImageExtensions = {'jpg', 'jpeg', 'png'};

  @override
  void initState() {
    nameController = TextEditingController(text: widget.teacherData.name);
    usernameController =
        TextEditingController(text: widget.teacherData.username);
    selectedModules = widget.teacherData.moduleAccess.toSet();
    selectedRole = widget.teacherData.role;
    super.initState();
  }

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
    final String password = passwordController.text;

    if (name.isEmpty || name.length > 100) {
      Helper.showSnackBarMessage(
          msg: "Please enter a name (up to 100 characters)", isSuccess: false);
      return;
    }

    // Optional here — non-empty means "change it", empty means "keep it".
    if (password.isNotEmpty && password.length < 8) {
      Helper.showSnackBarMessage(
          msg: "Password must be at least 8 characters", isSuccess: false);
      return;
    }

    final PlatformFile? imageFile = selectedImageFile;
    final Uint8List? imageBytes = selectedImageBytes;
    if (imageFile != null && imageBytes != null) {
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
    }

    if (selectedModules.isEmpty) {
      Helper.showSnackBarMessage(
          msg: "Please select at least one module", isSuccess: false);
      return;
    }

    // Preserve moduleList's order rather than Set iteration order, which is
    // insertion-order-dependent and would make the saved list order flaky.
    final List<String> moduleAccess =
        moduleList.where(selectedModules.contains).toList();

    setState(() => isSaving = true);
    final TeacherViewModel teacherViewModel =
        Provider.of<TeacherViewModel>(context, listen: false);
    final bool success = await teacherViewModel.updateTeacher(
      original: widget.teacherData,
      name: name,
      newPassword: password.isEmpty ? null : password,
      moduleAccess: moduleAccess,
      role: selectedRole,
      newImage: imageBytes,
    );

    if (!mounted) return;
    if (success) {
      Helper.showSnackBarMessage(
          msg: "Teacher updated successfully", isSuccess: true);
      Navigator.pop(context);
    } else {
      setState(() => isSaving = false);
    }
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.4,
        color: AppColorsInApp.colorGrey,
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 104,
                width: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColorsInApp.colorGrey.withValues(alpha: .12),
                  image: selectedImageBytes != null
                      ? DecorationImage(
                          image: MemoryImage(selectedImageBytes!),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: NetworkImage(widget.teacherData.imageUrl),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {},
                        ),
                ),
                alignment: Alignment.center,
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _onSelectImage,
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColorsInApp.colorSecondary,
                      border: Border.all(
                          color: AppColorsInApp.colorWhite, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 16, color: AppColorsInApp.colorWhite),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            selectedImageBytes == null
                ? "Tap the camera to change the photo"
                : "Photo selected — tap to change",
            style: TextStyle(
                fontSize: 12,
                color: AppColorsInApp.colorGrey.withValues(alpha: .9)),
          ),
          const SizedBox(height: 2),
          Text(
            "JPG or PNG, up to 5MB",
            style: TextStyle(
                fontSize: 11,
                color: AppColorsInApp.colorGrey.withValues(alpha: .7)),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) => role[0].toUpperCase() + role.substring(1);

  Widget _buildRoleChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final role in roleList)
          ChoiceChip(
            key: Key('role_option_$role'),
            label: Text(
              _roleLabel(role),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selectedRole == role
                    ? AppColorsInApp.colorWhite
                    : AppColorsInApp.colorBlack1,
              ),
            ),
            showCheckmark: false,
            selected: selectedRole == role,
            selectedColor: AppColorsInApp.colorSecondary,
            backgroundColor: AppColorsInApp.colorGrey.withValues(alpha: .08),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            onSelected: (checked) {
              if (!checked) return;
              setState(() => selectedRole = role);
            },
          ),
      ],
    );
  }

  Widget _buildModuleAccessChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (int i = 0; i < moduleList.length; i++)
          FilterChip(
            key: Key('module_checkbox_${moduleList[i]}'),
            avatar: Icon(
              moduleIconList[i],
              size: 17,
              color: selectedModules.contains(moduleList[i])
                  ? AppColorsInApp.colorWhite
                  : AppColorsInApp.colorGrey,
            ),
            label: Text(
              moduleList[i],
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selectedModules.contains(moduleList[i])
                    ? AppColorsInApp.colorWhite
                    : AppColorsInApp.colorBlack1,
              ),
            ),
            showCheckmark: false,
            selected: selectedModules.contains(moduleList[i]),
            selectedColor: AppColorsInApp.colorSecondary,
            backgroundColor: AppColorsInApp.colorGrey.withValues(alpha: .08),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            onSelected: (checked) {
              setState(() {
                if (checked) {
                  selectedModules.add(moduleList[i]);
                } else {
                  selectedModules.remove(moduleList[i]);
                }
              });
            },
          ),
      ],
    );
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
                    child: Container(
                      color: AppColorsInApp.colorGrey.withValues(alpha: .06),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: width < 900 ? 16 : 40,
                          vertical: 30,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: AppColorsInApp.colorWhite,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColorsInApp.colorGrey
                                        .withValues(alpha: .18),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Edit Teacher",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColorsInApp.colorBlack1),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Update the login and module access for this teacher.",
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppColorsInApp.colorGrey
                                            .withValues(alpha: .9)),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildAvatarPicker(),
                                  const SizedBox(height: 28),
                                  _sectionLabel("BASIC INFORMATION"),
                                  const SizedBox(height: 14),
                                  CustomTextField(
                                    key: const Key('teacher_name_field'),
                                    labelText: "name",
                                    title: "Name",
                                    textEditingController: nameController,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    key: const Key('teacher_username_field'),
                                    labelText: "username",
                                    title: "Username",
                                    textEditingController: usernameController,
                                    enabled: false,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      "Username can't be changed once created.",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColorsInApp.colorGrey
                                              .withValues(alpha: .9)),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
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
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      "Leave blank to keep the current password. Min 8 characters otherwise.",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColorsInApp.colorGrey
                                              .withValues(alpha: .9)),
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  _sectionLabel("ROLE"),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Choose the access level for this teacher.",
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppColorsInApp.colorGrey
                                            .withValues(alpha: .9)),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildRoleChips(),
                                  const SizedBox(height: 28),
                                  _sectionLabel("MODULE ACCESS"),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Select the sections this teacher can manage.",
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppColorsInApp.colorGrey
                                            .withValues(alpha: .9)),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildModuleAccessChips(),
                                  const SizedBox(height: 32),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: isSaving
                                            ? null
                                            : () => Navigator.pop(context),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          side: BorderSide(
                                              color: AppColorsInApp.colorGrey
                                                  .withValues(alpha: .5)),
                                        ),
                                        child: const Text("Cancel",
                                            style: TextStyle(
                                                color: AppColorsInApp
                                                    .colorBlack1)),
                                      ),
                                      const SizedBox(width: 12),
                                      isSaving
                                          ? const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12),
                                              child: SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2.5),
                                              ),
                                            )
                                          : SaveButton(
                                              key: const Key(
                                                  'teacher_save_button'),
                                              onPRess: _onSave,
                                              buttonColor: AppColorsInApp
                                                  .colorSecondary,
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
