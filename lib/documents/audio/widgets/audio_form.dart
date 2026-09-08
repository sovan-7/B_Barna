import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/course/widgets/course_form.dart' show UpperCaseTextFormatter;
import 'package:bbarna/documents/audio/model/audio_model.dart';
import 'package:bbarna/documents/audio/viewModel/audio_view_model.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// The whole Add/Edit Audio page. [existing] null means Add.
///
/// Add and Edit were two 281 and 297 line screens holding the same form
/// twice over. There is one responsive form here, and the two screens in
/// `screen/` just choose the mode.
class AudioForm extends StatefulWidget {
  final AudioModel? existing;
  const AudioForm({this.existing, super.key});

  bool get isEdit => existing != null;

  @override
  State<AudioForm> createState() => _AudioFormState();
}

enum _Field { code, title, file, type }

class _AudioFormState extends State<AudioForm> {
  final GlobalKey<ScaffoldState> key = GlobalKey();

  final TextEditingController codeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  Uint8List? selectedAudioBytes;
  String audioName = "";

  static const List<String> audioTypeList = ["FREE", "PAID"];
  String? _selectedType;
  bool _isSaving = false;

  final Map<_Field, String> _errors = <_Field, String>{};

  @override
  void initState() {
    super.initState();
    final AudioModel? existing = widget.existing;
    if (existing != null) {
      codeController.text = existing.code;
      titleController.text = existing.title;
      descriptionController.text =
          existing.description == stringDefault ? "" : existing.description;
      _selectedType =
          audioTypeList.contains(existing.audioType) ? existing.audioType : null;
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Map<_Field, String> _validate() {
    final Map<_Field, String> errors = <_Field, String>{};
    if (codeController.text.trim().isEmpty) {
      errors[_Field.code] = "Give the clip a code";
    }
    if (titleController.text.trim().isEmpty) {
      errors[_Field.title] = "Give the clip a title";
    }

    // A file is only mandatory when creating: an edit keeps the one the
    // document already has.
    if (!widget.isEdit && selectedAudioBytes == null) {
      errors[_Field.file] = "Choose an audio file to upload";
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

  Future<void> _onSubmit(AudioViewModel audioViewModel) async {
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

    final AudioModel model = AudioModel(
      codeController.text.trim().toUpperCase(),
      descriptionController.text.trim(),
      titleController.text.trim(),
      widget.existing?.link ?? "",
      _selectedType ?? stringDefault,
      widget.existing?.timeStamp ?? DateTime.now().millisecondsSinceEpoch,
    );

    final bool success = widget.isEdit
        ? await audioViewModel.updateAudio(model, widget.existing!.docId,
            file: selectedAudioBytes)
        : await audioViewModel.createAudio(model, selectedAudioBytes!);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Helper.showSnackBarMessage(
          msg: widget.isEdit
              ? "Audio updated successfully"
              : "Audio added successfully",
          isSuccess: true);
      Navigator.pop(context);
    }
  }

  void _onDelete(AudioViewModel audioViewModel) {
    final AudioModel existing = widget.existing!;
    RemoveAlert.showRemoveAlert(
      title: existing.title,
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        Navigator.pop(navigatorKey.currentContext!);
        if (mounted) setState(() => _isSaving = true);
        final bool success = await audioViewModel.deleteAudio(existing.docId);
        if (!mounted) return;
        setState(() => _isSaving = false);
        if (success) {
          Helper.showInfoMessage(msg: "Audio deleted successfully");
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
              title: "Audio",
            ),
            Expanded(
              child: Row(
                children: [
                  if (!isCompact)
                    const Expanded(child: ExtraSideBar(sidebarIndex: 7)),
                  Expanded(
                    flex: 5,
                    child: Consumer<AudioViewModel>(
                      builder: (context, audioViewModel, child) =>
                          _page(audioViewModel, width),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer:
          isCompact ? const Drawer(child: ExtraSideBar(sidebarIndex: 7)) : null,
    );
  }

  Widget _page(AudioViewModel audioViewModel, double width) {
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
                    _section(title: "AUDIO DETAILS", children: [
                      _twoUp(
                        width,
                        _textField(
                          label: "Audio code",
                          hint: "e.g. LECTURE-01",
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
                        hint: "e.g. Kinematics — recorded lecture",
                        controller: titleController,
                        error: _errors[_Field.title],
                        onChanged: _revalidate,
                      ),
                      const SizedBox(height: AppTokens.gapMd),
                      _textField(
                        label: "Description",
                        hint: "What does this clip cover? (optional)",
                        controller: descriptionController,
                        maxLines: 4,
                      ),
                    ]),
                    const SizedBox(height: AppTokens.gapMd),
                    _section(title: "FILE", children: [_fileField()]),
                    const SizedBox(height: AppTokens.gapXl),
                  ],
                ),
              ),
            ),
          ),
        ),
        _actionBar(audioViewModel, width),
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
              Text(widget.isEdit ? "Edit audio" : "Add a clip",
                  style: AppTokens.pageTitle),
              const SizedBox(height: 3),
              Text(
                widget.isEdit
                    ? "Update this clip's details and file."
                    : "Upload a clip for students to play in the app.",
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
              for (final String type in audioTypeList)
                Expanded(
                  child: _segment(
                    key: Key('audio_type_${type.toLowerCase()}'),
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

  Future<void> _pickFile() async {
    final FilePickerResult? picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'aac'],
    );
    if (picked == null || !mounted) return;
    setState(() {
      selectedAudioBytes = picked.files.first.bytes;
      audioName = picked.files.first.name;
    });
    _revalidate();
  }

  /// The old picker was a grey "Choose Pdf" chip with the file name in
  /// plain text beside it, and no way to tell whether an edit already had
  /// a file attached.
  Widget _fileField() {
    final String? error = _errors[_Field.file];
    final bool hasNew = selectedAudioBytes != null;
    final bool hasExisting = (widget.existing?.link ?? "").trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: hasNew ? AppTokens.surface : AppTokens.surfaceMuted,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          child: InkWell(
            key: const Key('audio_choose_file'),
            onTap: _isSaving ? null : _pickFile,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 26),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(
                  color: error != null
                      ? AppTokens.danger
                      : AppTokens.inkFaint.withValues(alpha: .5),
                  width: 1.4,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                      hasNew
                          ? Icons.audio_file
                          : Icons.upload_file_outlined,
                      size: 30,
                      color: hasNew
                          ? const Color(0xFFD92D20)
                          : AppTokens.inkFaint),
                  const SizedBox(height: 10),
                  Text(
                    hasNew
                        ? (audioName.isEmpty ? "Selected file" : audioName)
                        : hasExisting
                            ? "Replace the current file"
                            : "Choose an audio file",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasNew
                        ? _readableSize(selectedAudioBytes!.lengthInBytes)
                        : hasExisting
                            ? "A file is already attached — leave this to keep it."
                            : "MP3 or M4A.",
                    style: const TextStyle(
                        fontSize: 12, color: AppTokens.inkFaint),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasNew) ...[
          const SizedBox(height: AppTokens.gapSm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isSaving
                  ? null
                  : () => setState(() {
                        selectedAudioBytes = null;
                        audioName = "";
                      }),
              style: TextButton.styleFrom(
                  foregroundColor: AppTokens.danger,
                  padding: const EdgeInsets.symmetric(horizontal: 10)),
              child:
                  const Text("Remove", style: TextStyle(fontSize: 12.5)),
            ),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(error, style: AppTokens.errorText),
        ],
      ],
    );
  }

  static String _readableSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(0)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  Widget _actionBar(AudioViewModel audioViewModel, double width) {
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
                            _isSaving ? null : () => _onDelete(audioViewModel),
                        tooltip: "Delete audio",
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppTokens.danger,
                      )
                    : TextButton.icon(
                        onPressed:
                            _isSaving ? null : () => _onDelete(audioViewModel),
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
              _saveButton(audioViewModel, expand: narrow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saveButton(AudioViewModel audioViewModel, {required bool expand}) {
    final Widget button = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 135, minHeight: 42),
      child: ElevatedButton(
        key: const Key('audio_save_button'),
        onPressed: _isSaving ? null : () => _onSubmit(audioViewModel),
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
            : Text(widget.isEdit ? "Update clip" : "Save clip",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600)),
      ),
    );

    return expand ? Expanded(child: button) : button;
  }
}
