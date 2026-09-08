import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/course/model/course_model.dart';
import 'package:bbarna/course/viewModel/course_view_model.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// The whole Add/Edit Course page. [existing] null means Add.
///
/// Add and Edit were two 450+ and 530+ line screens that each contained the
/// same form written out twice — once for wide windows and once for narrow
/// — so the same field existed in four places and drifted in all of them.
/// There is one responsive form here, and the two screens in `screen/`
/// just choose the mode.
class CourseForm extends StatefulWidget {
  final CourseModel? existing;
  const CourseForm({this.existing, super.key});

  bool get isEdit => existing != null;

  @override
  State<CourseForm> createState() => _CourseFormState();
}

/// The fields that can carry an inline error.
enum _Field { code, name, priority, image }

class _CourseFormState extends State<CourseForm> {
  final GlobalKey<ScaffoldState> key = GlobalKey();

  final TextEditingController codeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  Uint8List? selectedImageBytes;
  String imageName = "";
  bool willDisplay = false;
  bool isLocked = false;
  bool _isSaving = false;

  /// Populated on a failed submit and cleared per-field as it is corrected.
  /// The old form only ever reported the first problem, one snackbar at a
  /// time, with nothing marked on the field itself.
  final Map<_Field, String> _errors = <_Field, String>{};

  @override
  void initState() {
    super.initState();
    final CourseModel? existing = widget.existing;
    if (existing != null) {
      codeController.text = existing.code;
      nameController.text = existing.name;
      descriptionController.text =
          existing.description == stringDefault ? "" : existing.description;
      priorityController.text = existing.displayPriority.toString();
      willDisplay = existing.willDisplay;
      isLocked = existing.isLocked;
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    priorityController.dispose();
    super.dispose();
  }

  // ---- Validation -----------------------------------------------------

  Map<_Field, String> _validate() {
    final Map<_Field, String> errors = <_Field, String>{};
    if (codeController.text.trim().isEmpty) {
      errors[_Field.code] = "Give the course a code";
    }
    if (nameController.text.trim().isEmpty) {
      errors[_Field.name] = "Give the course a name";
    }
    final String priority = priorityController.text.trim();
    if (priority.isEmpty) {
      errors[_Field.priority] = "Set a display priority";
    } else if (int.tryParse(priority) == null) {
      errors[_Field.priority] = "Priority must be a whole number";
    }
    // An image is only mandatory when creating: an edit keeps the one the
    // course already has. The old form asked for one either way.
    if (!widget.isEdit && selectedImageBytes == null) {
      errors[_Field.image] = "Choose a course image";
    }
    return errors;
  }

  void _revalidate() {
    if (_errors.isEmpty) return;
    final Map<_Field, String> fresh = _validate();
    setState(() {
      _errors
        ..clear()
        ..addAll(fresh);
    });
  }

  Future<void> _pickImage() async {
    final FilePickerResult? picked =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (picked == null || !mounted) return;
    setState(() {
      selectedImageBytes = picked.files.first.bytes;
      imageName = picked.files.first.name;
    });
    _revalidate();
  }

  Future<void> _onSubmit(CourseViewModel courseViewModel) async {
    final Map<_Field, String> errors = _validate();
    if (errors.isNotEmpty) {
      setState(() {
        _errors
          ..clear()
          ..addAll(errors);
      });
      Helper.showSnackBarMessage(
          msg: errors.length == 1
              ? "Check the highlighted field"
              : "Check the ${errors.length} highlighted fields",
          isSuccess: false);
      return;
    }

    setState(() {
      _errors.clear();
      _isSaving = true;
    });

    final CourseModel model = CourseModel(
      codeController.text.trim().toUpperCase(),
      descriptionController.text.trim(),
      nameController.text.trim(),
      widget.existing?.image ?? "",
      int.parse(priorityController.text.trim()),
      widget.existing?.timeStamp ?? DateTime.now().millisecondsSinceEpoch,
      willDisplay,
      isLocked,
    );

    final bool success = widget.isEdit
        ? await courseViewModel.updateCourse(model, widget.existing!.docId,
            image: selectedImageBytes)
        : await courseViewModel.createCourse(model, selectedImageBytes!);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Helper.showSnackBarMessage(
          msg: widget.isEdit
              ? "Course updated successfully"
              : "Course added successfully",
          isSuccess: true);
      Navigator.pop(context);
    }
  }

  void _onDelete(CourseViewModel courseViewModel) {
    final CourseModel existing = widget.existing!;
    RemoveAlert.showRemoveAlert(
      title: existing.name,
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        Navigator.pop(navigatorKey.currentContext!);
        if (mounted) setState(() => _isSaving = true);
        final bool success = await courseViewModel.deleteCourse(existing.docId);
        if (!mounted) return;
        setState(() => _isSaving = false);
        if (success) {
          Helper.showSnackBarMessage(
              msg: "Course deleted successfully", isSuccess: false);
          Navigator.pop(context);
        }
      },
    );
  }

  // ---- Layout ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isCompact = width < AppTokens.compactBreakpoint;

    return Scaffold(
      key: key,
      backgroundColor: AppTokens.canvas,
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
        },
        child: Column(
          children: [
            AppHeader(
              onTapIcon: () => key.currentState?.openDrawer(),
              title: "Courses",
            ),
            Expanded(
              child: Row(
                children: [
                  if (!isCompact)
                    const Expanded(child: ExtraSideBar(sidebarIndex: 1)),
                  Expanded(
                    flex: 5,
                    child: Consumer<CourseViewModel>(
                      builder: (context, courseViewModel, child) =>
                          _page(courseViewModel, width),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer:
          isCompact ? const Drawer(child: ExtraSideBar(sidebarIndex: 1)) : null,
    );
  }

  Widget _page(CourseViewModel courseViewModel, double width) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: width < 700 ? 16 : 32, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _pageHeader(),
                    const SizedBox(height: AppTokens.gapLg),
                    _section(title: "COURSE DETAILS", children: [
                      _twoUp(
                        width,
                        _textField(
                          label: "Course code",
                          hint: "e.g. PHY-11",
                          controller: codeController,
                          error: _errors[_Field.code],
                          onChanged: _revalidate,
                          uppercase: true,
                        ),
                        _textField(
                          label: "Display priority",
                          hint: "Lower numbers come first",
                          controller: priorityController,
                          error: _errors[_Field.priority],
                          onChanged: _revalidate,
                          numeric: true,
                        ),
                      ),
                      const SizedBox(height: AppTokens.gapMd),
                      _textField(
                        label: "Course name",
                        hint: "e.g. Physics — Class 11",
                        controller: nameController,
                        error: _errors[_Field.name],
                        onChanged: _revalidate,
                      ),
                      const SizedBox(height: AppTokens.gapMd),
                      _textField(
                        label: "Description",
                        hint: "What does this course cover? (optional)",
                        controller: descriptionController,
                        maxLines: 4,
                      ),
                    ]),
                    const SizedBox(height: AppTokens.gapMd),
                    _section(title: "COURSE IMAGE", children: [_imageField()]),
                    const SizedBox(height: AppTokens.gapMd),
                    _section(title: "AVAILABILITY", children: [
                      _toggleRow(
                        title: "Show in the app",
                        subtitle:
                            "Hidden courses stay in the catalogue but students never see them.",
                        value: willDisplay,
                        onChanged: (value) =>
                            setState(() => willDisplay = value),
                      ),
                      const Divider(
                          height: AppTokens.gapLg,
                          thickness: 1,
                          color: AppTokens.hairline),
                      _toggleRow(
                        title: "Locked",
                        subtitle:
                            "Students can see a locked course but cannot open its content.",
                        value: isLocked,
                        onChanged: (value) => setState(() => isLocked = value),
                      ),
                    ]),
                    const SizedBox(height: AppTokens.gapXl),
                  ],
                ),
              ),
            ),
          ),
        ),
        _actionBar(courseViewModel, width),
      ],
    );
  }

  /// Side by side on a desktop, stacked on a phone.
  Widget _twoUp(double width, Widget left, Widget right) {
    if (width < 700) {
      return Column(children: [
        left,
        const SizedBox(height: AppTokens.gapMd),
        right,
      ]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: AppTokens.gapMd),
        Expanded(child: right),
      ],
    );
  }

  Widget _pageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(),
        const SizedBox(width: AppTokens.gapMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.isEdit ? "Edit course" : "Add a course",
                  style: AppTokens.pageTitle),
              const SizedBox(height: 3),
              Text(
                widget.isEdit
                    ? "Update this course's details and availability."
                    : "Courses are the top level of the catalogue.",
                style: AppTokens.pageSubtitle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _backButton() {
    return Material(
      color: AppTokens.surface,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: InkWell(
        onTap: _isSaving ? null : () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: AppTokens.hairline),
          ),
          child: const Icon(Icons.arrow_back, size: 18, color: AppTokens.ink),
        ),
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: AppTokens.hairline),
        boxShadow: AppTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTokens.sectionTitle),
          const SizedBox(height: AppTokens.gapMd),
          ...children,
        ],
      ),
    );
  }

  /// A full-width bordered input. The shared [CustomTextField] is locked to
  /// `width: 350`, which is what left the old form as a narrow ribbon of
  /// controls in the middle of a wide page.
  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    String? error,
    VoidCallback? onChanged,
    bool numeric = false,
    bool uppercase = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTokens.navItemSelected.copyWith(fontSize: 12.5)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTokens.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(
                color: error != null ? AppTokens.danger : AppTokens.hairline),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: numeric ? TextInputType.number : TextInputType.text,
            inputFormatters: [
              if (numeric) FilteringTextInputFormatter.digitsOnly,
              if (uppercase) UpperCaseTextFormatter(),
            ],
            onChanged: onChanged == null ? null : (_) => onChanged(),
            style: const TextStyle(fontSize: 13.5, color: AppTokens.ink),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 13, color: AppTokens.inkFaint),
              contentPadding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 5),
          Text(error, style: AppTokens.errorText),
        ],
      ],
    );
  }

  /// A square well — courses render as a small square thumbnail in the
  /// list, so that is the shape previewed here.
  Widget _imageField() {
    final String? error = _errors[_Field.image];
    final bool hasNew = selectedImageBytes != null;
    final String existingUrl = widget.existing?.image ?? "";
    final bool hasExisting = existingUrl.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 108,
          width: 108,
          child: Material(
            color: AppTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            child: InkWell(
              onTap: _isSaving ? null : _pickImage,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(
                    color: error != null
                        ? AppTokens.danger
                        : AppTokens.inkFaint.withValues(alpha: .4),
                  ),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppTokens.radiusMd - 1),
                  child: hasNew
                      ? Image.memory(selectedImageBytes!, fit: BoxFit.cover)
                      : hasExisting
                          ? Image.network(existingUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => _imagePlaceholder())
                          : _imagePlaceholder(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTokens.gapMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasNew
                    ? (imageName.isEmpty ? "Selected image" : imageName)
                    : hasExisting
                        ? "Using the current image"
                        : "No image chosen",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.ink),
              ),
              const SizedBox(height: 3),
              Text(
                hasNew
                    ? _readableSize(selectedImageBytes!.lengthInBytes)
                    : "Square images work best — it is shown as a thumbnail.",
                style: const TextStyle(
                    fontSize: 11.5, height: 1.35, color: AppTokens.inkFaint),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _isSaving ? null : _pickImage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTokens.ink,
                      side: const BorderSide(color: AppTokens.hairline),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusSm)),
                    ),
                    child: Text(
                        hasNew || hasExisting ? "Replace" : "Choose image",
                        style: const TextStyle(fontSize: 12.5)),
                  ),
                  if (hasNew) ...[
                    const SizedBox(width: AppTokens.gapSm),
                    TextButton(
                      onPressed: _isSaving
                          ? null
                          : () => setState(() {
                                selectedImageBytes = null;
                                imageName = "";
                              }),
                      style: TextButton.styleFrom(
                          foregroundColor: AppTokens.danger,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10)),
                      child: const Text("Remove",
                          style: TextStyle(fontSize: 12.5)),
                    ),
                  ],
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error, style: AppTokens.errorText),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() => Container(
        color: AppTokens.surfaceMuted,
        alignment: Alignment.center,
        child: const Icon(Icons.add_photo_alternate_outlined,
            size: 26, color: AppTokens.inkFaint),
      );

  static String _readableSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(0)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  /// A labelled switch with the consequence spelled out. These were two
  /// unlabelled `ToggleSwitch` widgets whose two states were "0" and "1"
  /// positions — nothing on screen said which meant what.
  Widget _toggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTokens.ink)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11.5, height: 1.35, color: AppTokens.inkFaint)),
            ],
          ),
        ),
        const SizedBox(width: AppTokens.gapMd),
        Switch(
          value: value,
          onChanged: _isSaving ? null : onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AppTokens.ink,
        ),
      ],
    );
  }

  Widget _actionBar(CourseViewModel courseViewModel, double width) {
    final bool narrow = width < 560;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: width < 700 ? 16 : 32, vertical: 14),
      decoration: const BoxDecoration(
        color: AppTokens.surface,
        border: Border(top: BorderSide(color: AppTokens.hairline)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Row(
            children: [
              if (widget.isEdit)
                narrow
                    ? IconButton(
                        onPressed:
                            _isSaving ? null : () => _onDelete(courseViewModel),
                        tooltip: "Delete course",
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppTokens.danger,
                      )
                    : TextButton.icon(
                        onPressed:
                            _isSaving ? null : () => _onDelete(courseViewModel),
                        icon: const Icon(Icons.delete_outline, size: 17),
                        label: const Text("Delete"),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTokens.danger,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                        ),
                      ),
              if (!narrow) const Spacer(),
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppTokens.inkMuted,
                  padding: EdgeInsets.symmetric(
                      horizontal: narrow ? 12 : 18, vertical: 14),
                ),
                child: const Text("Cancel"),
              ),
              const SizedBox(width: AppTokens.gapSm),
              _saveButton(courseViewModel, expand: narrow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saveButton(CourseViewModel courseViewModel,
      {required bool expand}) {
    final Widget button = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140, minHeight: 42),
      child: ElevatedButton(
        key: const Key('course_save_button'),
        onPressed: _isSaving ? null : () => _onSubmit(courseViewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.ink,
          disabledBackgroundColor: AppTokens.ink.withValues(alpha: .55),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2.2, color: Colors.white),
              )
            : Text(widget.isEdit ? "Update course" : "Save course",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600)),
      ),
    );

    return expand ? Expanded(child: button) : button;
  }
}

/// Course codes are stored upper-cased, so the field shows them that way
/// as you type rather than silently changing what you typed on save.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
