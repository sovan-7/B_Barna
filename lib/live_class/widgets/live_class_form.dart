import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/live_class/model/live_class_model.dart';
import 'package:bbarna/live_class/viewModel/live_class_view_model.dart';
import 'package:bbarna/live_class/widgets/live_class_status_badge.dart';
import 'package:bbarna/live_class/widgets/live_class_theme.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The whole Add/Edit Class page. [existing] null means Add; non-null means
/// Edit (fields pre-populated, Update + Delete instead of Save).
///
/// Add and Edit share one widget on purpose — the form is identical in both
/// modes, so the two thin screens in `screen/` just choose the mode.
///
/// The form is grouped into two sections (Details, Schedule) with a fixed
/// action bar at the bottom. Errors are shown inline under the offending
/// field rather than only as a snackbar, so a failed save points at what to
/// fix instead of making the admin re-read the whole form.
class LiveClassForm extends StatefulWidget {
  final LiveClassModel? existing;
  const LiveClassForm({this.existing, super.key});

  bool get isEdit => existing != null;

  @override
  State<LiveClassForm> createState() => _LiveClassFormState();
}

/// The fields that can carry an inline error.
enum _Field { title, teacher, start, end }

class _LiveClassFormState extends State<LiveClassForm> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController youtubeLinkController = TextEditingController();
  final TextEditingController teacherNameController = TextEditingController();
  final GlobalKey<ScaffoldState> key = GlobalKey();

  String? _selectedTeacher;
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  bool _isSaving = false;

  /// Populated on a failed submit and cleared per-field as it is corrected,
  /// so the form never scolds you about something you already fixed.
  final Map<_Field, String> _errors = <_Field, String>{};

  @override
  void initState() {
    super.initState();
    final LiveClassModel? existing = widget.existing;
    if (existing != null) {
      titleController.text = existing.title;
      descriptionController.text = existing.description;
      youtubeLinkController.text = existing.youtubeLink;
      teacherNameController.text = existing.teacherName;
      _selectedTeacher = existing.teacherName;
      _startDateTime = existing.startDateTime;
      _endDateTime = existing.endDateTime;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<LiveClassViewModel>(context, listen: false).getTeacherNames();
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    youtubeLinkController.dispose();
    teacherNameController.dispose();
    super.dispose();
  }

  // ---- Validation -----------------------------------------------------

  /// Returns the per-field errors for the current state. Empty means valid.
  Map<_Field, String> _validate() {
    final Map<_Field, String> errors = <_Field, String>{};
    if (titleController.text.trim().isEmpty) {
      errors[_Field.title] = "Give the class a title";
    }
    if ((_selectedTeacher ?? teacherNameController.text).trim().isEmpty) {
      errors[_Field.teacher] = "Choose or type a teacher";
    }
    if (_startDateTime == null) {
      errors[_Field.start] = "Pick when the class starts";
    }
    if (_endDateTime == null) {
      errors[_Field.end] = "Pick when the class ends";
    } else if (_startDateTime != null &&
        !_endDateTime!.isAfter(_startDateTime!)) {
      errors[_Field.end] = "The end must be after the start";
    }
    return errors;
  }

  /// Re-runs validation only once the admin has already seen errors — that
  /// is what makes a correction clear its message as you make it.
  void _revalidate() {
    if (_errors.isEmpty) return;
    final Map<_Field, String> fresh = _validate();
    setState(() {
      _errors
        ..clear()
        ..addAll(fresh);
    });
  }

  Future<void> _onSubmit(LiveClassViewModel liveClassViewModel) async {
    final Map<_Field, String> errors = _validate();
    if (errors.isNotEmpty) {
      setState(() {
        _errors
          ..clear()
          ..addAll(errors);
      });
      // The inline messages already say what is wrong and where; the
      // snackbar only has to get the admin looking at them.
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

    final LiveClassModel model = LiveClassModel(
      docId: widget.existing?.docId ?? stringDefault,
      title: titleController.text,
      description: descriptionController.text,
      youtubeLink: youtubeLinkController.text,
      teacherName: (_selectedTeacher ?? teacherNameController.text).trim(),
      startDateTime: _startDateTime!,
      endDateTime: _endDateTime!,
    );

    final bool success = widget.isEdit
        ? await liveClassViewModel.updateLiveClass(model)
        : await liveClassViewModel.addLiveClass(model);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Helper.showSnackBarMessage(
          msg: widget.isEdit
              ? "Class updated successfully"
              : "Class added successfully",
          isSuccess: true);
      Navigator.pop(context);
    }
  }

  void _onDelete(LiveClassViewModel liveClassViewModel) {
    final LiveClassModel existing = widget.existing!;
    RemoveAlert.showRemoveAlert(
      title: existing.title,
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        // RemoveAlert never closes itself — every caller pops it. Popping it
        // first means the only route left to unwind on success is this form.
        Navigator.pop(navigatorKey.currentContext!);
        if (mounted) setState(() => _isSaving = true);
        final bool success =
            await liveClassViewModel.deleteLiveClass(existing.docId);
        if (!mounted) return;
        setState(() => _isSaving = false);
        if (success) {
          Helper.showSnackBarMessage(
              msg: "Class deleted successfully", isSuccess: false);
          // Back to the list.
          Navigator.pop(context);
        }
      },
    );
  }

  /// Date first, then time, both defaulting to whatever is already chosen.
  /// Returns null if the admin backs out of either step.
  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final DateTime now = DateTime.now();
    final DateTime base = initial ?? now;
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return null;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // ---- Layout ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: key,
      backgroundColor: LiveClassTheme.canvas,
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
        },
        child: Column(
          children: [
            AppHeader(onTapIcon: () => key.currentState?.openDrawer()),
            Expanded(
              child: Row(
                children: [
                  if (width > 900)
                    const Expanded(
                        child: ExtraSideBar(sidebarIndex: liveClassModuleIndex)),
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: LiveClassTheme.canvas,
                      child: Consumer<LiveClassViewModel>(
                        builder: (context, liveClassViewModel, child) =>
                            _page(liveClassViewModel, width),
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
          ? const Drawer(child: ExtraSideBar(sidebarIndex: liveClassModuleIndex))
          : null,
    );
  }

  /// Scrolling body + a fixed action bar. The bar being pinned means Save is
  /// reachable without scrolling to the bottom of a long form.
  Widget _page(LiveClassViewModel liveClassViewModel, double width) {
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
                    const SizedBox(height: LiveClassTheme.gapLg),
                    _section(
                      title: "CLASS DETAILS",
                      children: [
                        _textField(
                          label: "Class title",
                          hint: "e.g. Trigonometry — Chapter 4 revision",
                          controller: titleController,
                          error: _errors[_Field.title],
                          onChanged: _revalidate,
                        ),
                        const SizedBox(height: LiveClassTheme.gapMd),
                        _textField(
                          label: "Description",
                          hint: "What will this class cover? (optional)",
                          controller: descriptionController,
                          maxLines: 4,
                        ),
                        const SizedBox(height: LiveClassTheme.gapMd),
                        _teacherField(liveClassViewModel),
                        const SizedBox(height: LiveClassTheme.gapMd),
                        _textField(
                          label: "YouTube class link",
                          hint: "https://www.youtube.com/watch?v=...",
                          controller: youtubeLinkController,
                          prefixIcon: Icons.play_circle_outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: LiveClassTheme.gapMd),
                    _section(
                      title: "SCHEDULE",
                      children: [_scheduleFields(width)],
                    ),
                    const SizedBox(height: LiveClassTheme.gapXl),
                  ],
                ),
              ),
            ),
          ),
        ),
        _actionBar(liveClassViewModel, width),
      ],
    );
  }

  Widget _pageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(),
        const SizedBox(width: LiveClassTheme.gapMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEdit ? "Edit class" : "Schedule a class",
                style: LiveClassTheme.pageTitle,
              ),
              const SizedBox(height: 3),
              Text(
                widget.isEdit
                    ? "Update the schedule or details of this live class."
                    : "Set up a new live class for your students.",
                style: LiveClassTheme.pageSubtitle,
              ),
            ],
          ),
        ),
        // On edit, show what bucket the class currently lands in — and keep
        // it live as the dates are changed, so moving a class out of "Past"
        // is visible before saving.
        if (widget.isEdit && _startDateTime != null && _endDateTime != null)
          LiveClassStatusBadge(status: _previewModel().status),
      ],
    );
  }

  LiveClassModel _previewModel() => LiveClassModel(
        docId: widget.existing?.docId ?? stringDefault,
        title: titleController.text,
        description: descriptionController.text,
        youtubeLink: youtubeLinkController.text,
        teacherName: _selectedTeacher ?? "",
        startDateTime: _startDateTime!,
        endDateTime: _endDateTime!,
      );

  Widget _backButton() {
    return Material(
      color: LiveClassTheme.surface,
      borderRadius: BorderRadius.circular(LiveClassTheme.radiusMd),
      child: InkWell(
        onTap: _isSaving ? null : () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(LiveClassTheme.radiusMd),
        child: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LiveClassTheme.radiusMd),
            border: Border.all(color: LiveClassTheme.hairline),
          ),
          child: const Icon(Icons.arrow_back,
              size: 18, color: LiveClassTheme.ink),
        ),
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      decoration: BoxDecoration(
        color: LiveClassTheme.surface,
        borderRadius: BorderRadius.circular(LiveClassTheme.radiusLg),
        border: Border.all(color: LiveClassTheme.hairline),
        boxShadow: LiveClassTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: LiveClassTheme.sectionTitle),
          const SizedBox(height: LiveClassTheme.gapMd),
          ...children,
        ],
      ),
    );
  }

  // ---- Fields ---------------------------------------------------------

  /// A full-width bordered input. The shared [CustomTextField] is locked to
  /// `width: 350`, which is what left the old form as a narrow ribbon of
  /// controls in the middle of a wide page.
  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    String? error,
    IconData? prefixIcon,
    VoidCallback? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: LiveClassTheme.fieldLabel),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: LiveClassTheme.surface,
            borderRadius: BorderRadius.circular(LiveClassTheme.radiusMd),
            border: Border.all(
                color: error != null
                    ? LiveClassTheme.danger
                    : LiveClassTheme.hairline),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: onChanged == null ? null : (_) => onChanged(),
            style: const TextStyle(fontSize: 13.5, color: LiveClassTheme.ink),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                  fontSize: 13, color: LiveClassTheme.inkFaint),
              prefixIcon: prefixIcon == null
                  ? null
                  : Icon(prefixIcon, size: 17, color: LiveClassTheme.inkFaint),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 38, minHeight: 20),
              contentPadding: EdgeInsets.fromLTRB(
                  prefixIcon == null ? 14 : 0, 13, 14, 13),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 5),
          Text(error, style: LiveClassTheme.errorText),
        ],
      ],
    );
  }

  /// Dropdown of names from the `teacher` collection. Falls back to a plain
  /// text field only when that collection is empty (or unreachable), so the
  /// form is never a dead end.
  Widget _teacherField(LiveClassViewModel liveClassViewModel) {
    final List<String> names = [...liveClassViewModel.teacherNames];
    // An existing class may name a teacher who has since been removed —
    // keep that value selectable so editing doesn't silently drop it.
    final String? current = _selectedTeacher;
    if (current != null && current.isNotEmpty && !names.contains(current)) {
      names.insert(0, current);
    }

    if (names.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField(
            label: "Teacher",
            hint: "Type the teacher's name",
            controller: teacherNameController,
            error: _errors[_Field.teacher],
            onChanged: _revalidate,
          ),
          const SizedBox(height: 5),
          const Text(
            "No teachers found — type the name instead.",
            style: TextStyle(fontSize: 11.5, color: LiveClassTheme.inkFaint),
          ),
        ],
      );
    }

    // Keep _selectedTeacher in step with the free-text fallback if the
    // dropdown appears after the admin already typed a name.
    if ((_selectedTeacher ?? "").isEmpty &&
        teacherNameController.text.trim().isNotEmpty) {
      _selectedTeacher = teacherNameController.text.trim();
      if (!names.contains(_selectedTeacher)) names.insert(0, _selectedTeacher!);
    }

    final String? error = _errors[_Field.teacher];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Teacher", style: LiveClassTheme.fieldLabel),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: LiveClassTheme.surface,
            borderRadius: BorderRadius.circular(LiveClassTheme.radiusMd),
            border: Border.all(
                color: error != null
                    ? LiveClassTheme.danger
                    : LiveClassTheme.hairline),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: const Key('live_class_teacher_dropdown'),
              value: _selectedTeacher,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              borderRadius: BorderRadius.circular(LiveClassTheme.radiusMd),
              icon: const Icon(Icons.keyboard_arrow_down,
                  size: 20, color: LiveClassTheme.inkFaint),
              hint: const Text("Select a teacher",
                  style: TextStyle(
                      fontSize: 13, color: LiveClassTheme.inkFaint)),
              // Derived from the ambient style rather than written from
              // scratch: DropdownButton uses `style` as-is instead of
              // merging it, so a literal TextStyle here would silently drop
              // the app's font family if one is ever set on the theme.
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontSize: 13.5, color: LiveClassTheme.ink),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTeacher = newValue;
                  teacherNameController.text = newValue ?? "";
                });
                _revalidate();
              },
              items: names
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline,
                                size: 15, color: LiveClassTheme.inkFaint),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(value,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 5),
          Text(error, style: LiveClassTheme.errorText),
        ],
      ],
    );
  }

  /// Start and end sit side by side above a summary line, so the length of
  /// the class is something you read rather than compute.
  Widget _scheduleFields(double width) {
    final bool stack = width < 700;
    final Widget start = _dateTimeField(
      label: "Starts",
      value: _startDateTime,
      error: _errors[_Field.start],
      onPick: () async {
        final DateTime? picked = await _pickDateTime(_startDateTime);
        if (picked == null) return;
        setState(() {
          _startDateTime = picked;
          // Keep the pair coherent: an end that is now in the past
          // relative to the new start is cleared rather than silently
          // left invalid.
          if (_endDateTime != null && !_endDateTime!.isAfter(picked)) {
            _endDateTime = null;
          }
        });
        _revalidate();
      },
    );
    final Widget end = _dateTimeField(
      label: "Ends",
      value: _endDateTime,
      error: _errors[_Field.end],
      onPick: () async {
        final DateTime? picked =
            await _pickDateTime(_endDateTime ?? _startDateTime);
        if (picked == null) return;
        setState(() => _endDateTime = picked);
        _revalidate();
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stack)
          Column(children: [
            start,
            const SizedBox(height: LiveClassTheme.gapMd),
            end,
          ])
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: start),
              const SizedBox(width: LiveClassTheme.gapMd),
              Expanded(child: end),
            ],
          ),
        if (_startDateTime != null &&
            _endDateTime != null &&
            _endDateTime!.isAfter(_startDateTime!)) ...[
          const SizedBox(height: LiveClassTheme.gapMd),
          _scheduleSummary(),
        ],
      ],
    );
  }

  Widget _scheduleSummary() {
    final LiveClassStatus status = _previewModel().status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: LiveClassTheme.tintFor(status),
        borderRadius: BorderRadius.circular(LiveClassTheme.radiusMd),
        border: Border.all(color: LiveClassTheme.borderFor(status)),
      ),
      child: Row(
        children: [
          Icon(LiveClassTheme.iconFor(status),
              size: 16, color: LiveClassTheme.accentFor(status)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${LiveClassFormat.weekday.format(_startDateTime!)}, "
              "${LiveClassFormat.schedule(_previewModel())}  ·  "
              "${LiveClassFormat.duration(_startDateTime!, _endDateTime!)}",
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: LiveClassTheme.accentFor(status)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateTimeField({
    required String label,
    required DateTime? value,
    required VoidCallback onPick,
    String? error,
  }) {
    final bool isSet = value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: LiveClassTheme.fieldLabel),
        const SizedBox(height: 6),
        Material(
          color: LiveClassTheme.surface,
          borderRadius: BorderRadius.circular(LiveClassTheme.radiusMd),
          child: InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(LiveClassTheme.radiusMd),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(LiveClassTheme.radiusMd),
                border: Border.all(
                    color: error != null
                        ? LiveClassTheme.danger
                        : LiveClassTheme.hairline),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_outlined,
                      size: 17,
                      color: isSet
                          ? LiveClassTheme.inkMuted
                          : LiveClassTheme.inkFaint),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isSet
                          ? LiveClassFormat.full.format(value)
                          : "Select date & time",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isSet ? FontWeight.w600 : FontWeight.normal,
                        color: isSet
                            ? LiveClassTheme.ink
                            : LiveClassTheme.inkFaint,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 18, color: LiveClassTheme.inkFaint),
                ],
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 5),
          Text(error, style: LiveClassTheme.errorText),
        ],
      ],
    );
  }

  // ---- Action bar -----------------------------------------------------

  Widget _actionBar(LiveClassViewModel liveClassViewModel, double width) {
    // Under ~560px the three buttons stop fitting side by side, so Delete
    // drops to an icon and Save takes the remaining width — the usual
    // mobile shape, and it keeps Save the biggest target on the bar.
    final bool narrow = width < 560;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: width < 700 ? 16 : 32, vertical: 14),
      decoration: const BoxDecoration(
        color: LiveClassTheme.surface,
        border: Border(top: BorderSide(color: LiveClassTheme.hairline)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Row(
            children: [
              if (widget.isEdit)
                narrow
                    ? IconButton(
                        onPressed: _isSaving
                            ? null
                            : () => _onDelete(liveClassViewModel),
                        tooltip: "Delete class",
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: LiveClassTheme.danger,
                      )
                    : TextButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () => _onDelete(liveClassViewModel),
                        icon: const Icon(Icons.delete_outline, size: 17),
                        label: const Text("Delete"),
                        style: TextButton.styleFrom(
                          foregroundColor: LiveClassTheme.danger,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                        ),
                      ),
              if (!narrow) const Spacer(),
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: LiveClassTheme.inkMuted,
                  padding: EdgeInsets.symmetric(
                      horizontal: narrow ? 12 : 18, vertical: 14),
                ),
                child: const Text("Cancel"),
              ),
              const SizedBox(width: LiveClassTheme.gapSm),
              narrow
                  ? Expanded(child: _saveButton(liveClassViewModel))
                  : _saveButton(liveClassViewModel),
            ],
          ),
        ),
      ),
    );
  }

  /// Keeps its width while saving so the bar doesn't twitch — the label is
  /// swapped for a spinner in place.
  Widget _saveButton(LiveClassViewModel liveClassViewModel) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 132, minHeight: 42),
      child: ElevatedButton(
        key: const Key('live_class_save_button'),
        onPressed: _isSaving ? null : () => _onSubmit(liveClassViewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: LiveClassTheme.ink,
          disabledBackgroundColor: LiveClassTheme.ink.withValues(alpha: .55),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LiveClassTheme.radiusMd)),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2.2, color: Colors.white),
              )
            : Text(
                widget.isEdit ? "Update class" : "Save class",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
