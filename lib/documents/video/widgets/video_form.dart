import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/course/widgets/course_form.dart' show UpperCaseTextFormatter;
import 'package:bbarna/documents/video/model/video_model.dart';
import 'package:bbarna/documents/video/viewModel/video_view_model.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The whole Add/Edit Video page. [existing] null means Add.
///
/// Add and Edit were two 273 and 298 line screens holding the same form
/// twice over. There is one responsive form here, and the two screens in
/// `screen/` just choose the mode.
class VideoForm extends StatefulWidget {
  final VideoModel? existing;
  const VideoForm({this.existing, super.key});

  bool get isEdit => existing != null;

  @override
  State<VideoForm> createState() => _VideoFormState();
}

enum _Field { code, title, link, type }

class _VideoFormState extends State<VideoForm> {
  final GlobalKey<ScaffoldState> key = GlobalKey();

  final TextEditingController codeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  static const List<String> videoTypeList = ["FREE", "PAID"];
  String? _selectedType;
  bool _isSaving = false;

  final Map<_Field, String> _errors = <_Field, String>{};

  @override
  void initState() {
    super.initState();
    final VideoModel? existing = widget.existing;
    if (existing != null) {
      codeController.text = existing.code;
      titleController.text = existing.title;
      descriptionController.text =
          existing.description == stringDefault ? "" : existing.description;
      linkController.text =
          existing.link == stringDefault ? "" : existing.link;
      _selectedType =
          videoTypeList.contains(existing.videoType) ? existing.videoType : null;
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    super.dispose();
  }

  Map<_Field, String> _validate() {
    final Map<_Field, String> errors = <_Field, String>{};
    if (codeController.text.trim().isEmpty) {
      errors[_Field.code] = "Give the video a code";
    }
    if (titleController.text.trim().isEmpty) {
      errors[_Field.title] = "Give the video a title";
    }

    final String link = linkController.text.trim();
    if (link.isEmpty) {
      errors[_Field.link] = "Add the video link";
    } else {
      // Nothing checked this before, so a typo saved a row the app could
      // never play.
      final Uri? uri = Uri.tryParse(link);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        errors[_Field.link] = "That does not look like a full URL";
      }
    }

    if ((_selectedType ?? "").isEmpty) {
      errors[_Field.type] = "Choose whether it is free or paid";
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

  Future<void> _onSubmit(VideoViewModel videoViewModel) async {
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

    final VideoModel model = VideoModel(
      codeController.text.trim().toUpperCase(),
      descriptionController.text.trim(),
      titleController.text.trim(),
      linkController.text.trim(),
      _selectedType ?? stringDefault,
      widget.existing?.timeStamp ?? DateTime.now().millisecondsSinceEpoch,
    );

    final bool success = widget.isEdit
        ? await videoViewModel.updateVideo(model, widget.existing!.docId)
        : await videoViewModel.addVideo(model);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Helper.showSnackBarMessage(
          msg: widget.isEdit
              ? "Video updated successfully"
              : "Video added successfully",
          isSuccess: true);
      Navigator.pop(context);
    }
  }

  void _onDelete(VideoViewModel videoViewModel) {
    final VideoModel existing = widget.existing!;
    RemoveAlert.showRemoveAlert(
      title: existing.title,
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        Navigator.pop(navigatorKey.currentContext!);
        if (mounted) setState(() => _isSaving = true);
        final bool success = await videoViewModel.deleteVideo(existing.docId);
        if (!mounted) return;
        setState(() => _isSaving = false);
        if (success) {
          Helper.showInfoMessage(msg: "Video deleted successfully");
          Navigator.pop(context);
        }
      },
    );
  }

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
              title: "Videos",
            ),
            Expanded(
              child: Row(
                children: [
                  if (!isCompact)
                    const Expanded(child: ExtraSideBar(sidebarIndex: 5)),
                  Expanded(
                    flex: 5,
                    child: Consumer<VideoViewModel>(
                      builder: (context, videoViewModel, child) =>
                          _page(videoViewModel, width),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer:
          isCompact ? const Drawer(child: ExtraSideBar(sidebarIndex: 5)) : null,
    );
  }

  Widget _page(VideoViewModel videoViewModel, double width) {
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
                    _section(title: "VIDEO DETAILS", children: [
                      _twoUp(
                        width,
                        _textField(
                          label: "Video code",
                          hint: "e.g. INTRO-01",
                          controller: codeController,
                          error: _errors[_Field.code],
                          onChanged: _revalidate,
                          uppercase: true,
                        ),
                        _typeField(),
                      ),
                      const SizedBox(height: AppTokens.gapMd),
                      _textField(
                        label: "Title",
                        hint: "e.g. Introduction to Kinematics",
                        controller: titleController,
                        error: _errors[_Field.title],
                        onChanged: _revalidate,
                      ),
                      const SizedBox(height: AppTokens.gapMd),
                      _textField(
                        label: "Description",
                        hint: "What does this video cover? (optional)",
                        controller: descriptionController,
                        maxLines: 4,
                      ),
                    ]),
                    const SizedBox(height: AppTokens.gapMd),
                    _section(title: "LINK", children: [
                      _textField(
                        label: "Video link",
                        hint: "https://www.youtube.com/watch?v=...",
                        controller: linkController,
                        error: _errors[_Field.link],
                        onChanged: _revalidate,
                        prefixIcon: Icons.link,
                      ),
                    ]),
                    const SizedBox(height: AppTokens.gapXl),
                  ],
                ),
              ),
            ),
          ),
        ),
        _actionBar(videoViewModel, width),
      ],
    );
  }

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
              Text(widget.isEdit ? "Edit video" : "Add a video",
                  style: AppTokens.pageTitle),
              const SizedBox(height: 3),
              Text(
                widget.isEdit
                    ? "Update this video's details and link."
                    : "Videos are linked, not uploaded.",
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

  static const TextStyle _labelStyle = TextStyle(
      fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF344054));

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    String? error,
    VoidCallback? onChanged,
    bool uppercase = false,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
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
            inputFormatters: [if (uppercase) UpperCaseTextFormatter()],
            onChanged: onChanged == null ? null : (_) => onChanged(),
            style: const TextStyle(fontSize: 13.5, color: AppTokens.ink),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 13, color: AppTokens.inkFaint),
              prefixIcon: prefixIcon == null
                  ? null
                  : Icon(prefixIcon, size: 17, color: AppTokens.inkFaint),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 38, minHeight: 20),
              contentPadding:
                  EdgeInsets.fromLTRB(prefixIcon == null ? 14 : 0, 13, 14, 13),
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

  /// FREE or PAID as two segments rather than a dropdown: with exactly two
  /// options, a dropdown hides half the answer behind a tap.
  Widget _typeField() {
    final String? error = _errors[_Field.type];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Access", style: _labelStyle),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppTokens.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(
                color: error != null ? AppTokens.danger : AppTokens.hairline),
          ),
          child: Row(
            children: [
              for (final String type in videoTypeList)
                Expanded(
                  child: _segment(
                    key: Key('video_type_${type.toLowerCase()}'),
                    label: type == "FREE" ? "Free" : "Paid",
                    icon: type == "FREE"
                        ? Icons.lock_open_outlined
                        : Icons.paid_outlined,
                    selected: _selectedType == type,
                    onTap: () {
                      setState(() => _selectedType = type);
                      _revalidate();
                    },
                  ),
                ),
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 5),
          Text(error, style: AppTokens.errorText),
        ],
      ],
    );
  }

  Widget _segment({
    required Key key,
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: _isSaving ? null : onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppTokens.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 14,
                color: selected ? Colors.white : AppTokens.inkFaint),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppTokens.inkMuted)),
          ],
        ),
      ),
    );
  }

  Widget _actionBar(VideoViewModel videoViewModel, double width) {
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
                            _isSaving ? null : () => _onDelete(videoViewModel),
                        tooltip: "Delete video",
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppTokens.danger,
                      )
                    : TextButton.icon(
                        onPressed:
                            _isSaving ? null : () => _onDelete(videoViewModel),
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
              _saveButton(videoViewModel, expand: narrow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saveButton(VideoViewModel videoViewModel, {required bool expand}) {
    final Widget button = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 135, minHeight: 42),
      child: ElevatedButton(
        key: const Key('video_save_button'),
        onPressed: _isSaving ? null : () => _onSubmit(videoViewModel),
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
            : Text(widget.isEdit ? "Update video" : "Save video",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600)),
      ),
    );

    return expand ? Expanded(child: button) : button;
  }
}
