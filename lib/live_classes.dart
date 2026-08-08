// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
//
// class VideoLessonForm extends StatefulWidget {
//   const VideoLessonForm({super.key});
//
//   @override
//   State<VideoLessonForm> createState() => _VideoLessonFormState();
// }
//
// class _VideoLessonFormState extends State<VideoLessonForm> {
//   final _formKey = GlobalKey<FormState>();
//
//   // Controllers
//   final _urlController = TextEditingController();
//   final _startTimeController = TextEditingController();
//   final _endTimeController = TextEditingController();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//
//   // Dropdown values
//   String? _selectedTeacher;
//   String? _selectedSubject;
//
//   // Tag state
//   final Set<String> _selectedTags = {};
//
//   // Computed
//   bool _isValidYoutubeUrl = false;
//   String _duration = '';
//   int _descCharCount = 0;
//
//   final List<String> _teachers = [
//     'Ananya Sharma',
//     'Rajesh Mehta',
//     'Priya Nair',
//     'Suresh Iyer',
//     'Deepa Banerjee',
//   ];
//
//   final List<String> _subjects = [
//     'Mathematics',
//     'Physics',
//     'Chemistry',
//     'Biology',
//     'History',
//     'Geography',
//     'English',
//   ];
//
//   final List<String> _tags = [
//     'Chapter 1',
//     'Revision',
//     'Practice',
//     'Concept',
//     'Exam prep',
//   ];
//
//
//
//   void _onUrlChanged(String val) {
//     setState(() {
//       _isValidYoutubeUrl =
//           val.contains('youtube.com') || val.contains('youtu.be');
//     });
//   }
//
//   int _toSeconds(String time) {
//     final parts = time.split(':').map(int.tryParse).toList();
//     if (parts.length == 3 && parts.every((p) => p != null)) {
//       return parts[0]! * 3600 + parts[1]! * 60 + parts[2]!;
//     } else if (parts.length == 2 && parts.every((p) => p != null)) {
//       return parts[0]! * 60 + parts[1]!;
//     }
//     return 0;
//   }
//
//   void _calcDuration() {
//     final s = _startTimeController.text.trim();
//     final e = _endTimeController.text.trim();
//     if (s.isNotEmpty && e.isNotEmpty) {
//       final diff = _toSeconds(e) - _toSeconds(s);
//       if (diff > 0) {
//         final m = diff ~/ 60;
//         final sec = diff % 60;
//         setState(() => _duration = '${m}m ${sec}s');
//         return;
//       }
//     }
//     setState(() => _duration = '');
//   }
//
//   void _toggleTag(String tag) {
//     setState(() {
//       if (_selectedTags.contains(tag)) {
//         _selectedTags.remove(tag);
//       } else {
//         _selectedTags.add(tag);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _urlController.dispose();
//     _startTimeController.dispose();
//     _endTimeController.dispose();
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBg,
//       body: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 720),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildPageHeader(),
//                   const SizedBox(height: 24),
//                   _buildCard([
//                     _buildVideoSourceSection(),
//                     _buildDivider(),
//                     _buildTimeRangeSection(),
//                     _buildDivider(),
//                     _buildAssignmentSection(),
//                     _buildDivider(),
//                     _buildContentDetailsSection(),
//                     _buildDivider(),
//                     _buildActionsSection(),
//                   ]),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPageHeader() {
//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: kRed,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
//         ),
//         const SizedBox(width: 12),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Add Video Lesson',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: kTextPrimary,
//                 letterSpacing: -0.3,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               'Clip a YouTube video and assign to a class',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: kTextSecondary,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCard(List<Widget> children) {
//     return Container(
//       decoration: BoxDecoration(
//         color: kSurface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: kBorder, width: 0.5),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: children,
//       ),
//     );
//   }
//
//   Widget _buildDivider() {
//     return const Divider(height: 1, thickness: 0.5, color: kBorder);
//   }
//
//   Widget _buildSectionLabel(String label) {
//     return Text(
//       label,
//       style: const TextStyle(
//         fontSize: 10,
//         fontWeight: FontWeight.w700,
//         letterSpacing: 0.8,
//         color: kTextTertiary,
//       ),
//     );
//   }
//
//   // ─── VIDEO SOURCE ────────────────────────────────────────────────────────────
//
//   Widget _buildVideoSourceSection() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionLabel('VIDEO SOURCE'),
//           const SizedBox(height: 14),
//           _buildFieldLabel('YouTube URL', required: true),
//           const SizedBox(height: 6),
//           TextFormField(
//             controller: _urlController,
//             onChanged: _onUrlChanged,
//             decoration: _inputDecoration(
//               hint: 'https://youtube.com/watch?v=...',
//               prefixIcon: Icon(Icons.link_rounded,
//                   size: 18, color: kRed),
//             ),
//             validator: (v) =>
//             v == null || v.isEmpty ? 'YouTube URL is required' : null,
//           ),
//           if (_isValidYoutubeUrl) ...[
//             const SizedBox(height: 10),
//             _buildUrlPreview(),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildUrlPreview() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: kBg,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kBorder, width: 0.5),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 54,
//             height: 38,
//             decoration: BoxDecoration(
//               color: Colors.black87,
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Icon(Icons.play_circle_fill_rounded,
//                 color: kRed, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _urlController.text.length > 45
//                       ? '${_urlController.text.substring(0, 45)}…'
//                       : _urlController.text,
//                   style: const TextStyle(
//                       fontSize: 12, color: kTextSecondary),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 const Text('YouTube video detected',
//                     style: TextStyle(fontSize: 11, color: kTextTertiary)),
//               ],
//             ),
//           ),
//           const Icon(Icons.check_circle_rounded,
//               color: Color(0xFF2E7D32), size: 18),
//         ],
//       ),
//     );
//   }
//
//
//
//   Widget _buildTimeRangeSection() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionLabel('TIME RANGE'),
//           const SizedBox(height: 14),
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildFieldLabel('Start time'),
//                     const SizedBox(height: 6),
//                     TextFormField(
//                       controller: _startTimeController,
//                       onChanged: (_) => _calcDuration(),
//                       decoration: _inputDecoration(
//                         hint: '00:00:00',
//                         prefixIcon: const Icon(Icons.access_time_rounded,
//                             size: 18, color: kTextTertiary),
//                       ),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(RegExp(r'[\d:]')),
//                         LengthLimitingTextInputFormatter(8),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 22, left: 10, right: 10),
//                 child: Text('→',
//                     style: TextStyle(
//                         fontSize: 20,
//                         color: kTextTertiary,
//                         fontWeight: FontWeight.w300)),
//               ),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildFieldLabel('End time'),
//                     const SizedBox(height: 6),
//                     TextFormField(
//                       controller: _endTimeController,
//                       onChanged: (_) => _calcDuration(),
//                       decoration: _inputDecoration(
//                         hint: '00:00:00',
//                         prefixIcon: const Icon(Icons.access_time_rounded,
//                             size: 18, color: kTextTertiary),
//                       ),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(RegExp(r'[\d:]')),
//                         LengthLimitingTextInputFormatter(8),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_duration.isNotEmpty) ...[
//             const SizedBox(height: 10),
//             _buildDurationPill(),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDurationPill() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//       decoration: BoxDecoration(
//         color: kInfoBg,
//         borderRadius: BorderRadius.circular(99),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(Icons.timer_outlined, size: 14, color: kInfoText),
//           const SizedBox(width: 5),
//           Text('Duration: $_duration',
//               style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: kInfoText)),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildAssignmentSection() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionLabel('ASSIGNMENT'),
//           const SizedBox(height: 14),
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildFieldLabel('Teacher', required: true),
//                     const SizedBox(height: 6),
//                     DropdownButtonFormField<String>(
//                       value: _selectedTeacher,
//                       decoration: _inputDecoration(
//                         hint: 'Select teacher',
//                         prefixIcon: const Icon(Icons.person_outline_rounded,
//                             size: 18, color: kTextTertiary),
//                       ),
//                       items: _teachers
//                           .map((t) => DropdownMenuItem(
//                         value: t,
//                         child: Text(t,
//                             style:
//                             const TextStyle(fontSize: 14)),
//                       ))
//                           .toList(),
//                       onChanged: (v) => setState(() => _selectedTeacher = v),
//                       validator: (v) =>
//                       v == null ? 'Please select a teacher' : null,
//                       icon: const Icon(Icons.keyboard_arrow_down_rounded,
//                           color: kTextTertiary, size: 20),
//                       isExpanded: true,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildFieldLabel('Subject', required: true),
//                     const SizedBox(height: 6),
//                     DropdownButtonFormField<String>(
//                       value: _selectedSubject,
//                       decoration: _inputDecoration(
//                         hint: 'Select subject',
//                         prefixIcon: const Icon(Icons.menu_book_outlined,
//                             size: 18, color: kTextTertiary),
//                       ),
//                       items: _subjects
//                           .map((s) => DropdownMenuItem(
//                         value: s,
//                         child: Text(s,
//                             style:
//                             const TextStyle(fontSize: 14)),
//                       ))
//                           .toList(),
//                       onChanged: (v) => setState(() => _selectedSubject = v),
//                       validator: (v) =>
//                       v == null ? 'Please select a subject' : null,
//                       icon: const Icon(Icons.keyboard_arrow_down_rounded,
//                           color: kTextTertiary, size: 20),
//                       isExpanded: true,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           const Text(
//             'Quick topic tags',
//             style: TextStyle(fontSize: 11, color: kTextTertiary),
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: _tags.map((tag) => _buildTag(tag)).toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTag(String tag) {
//     final isActive = _selectedTags.contains(tag);
//     return GestureDetector(
//       onTap: () => _toggleTag(tag),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: isActive ? const Color(0x1AE53935) : kBg,
//           border: Border.all(
//             color: isActive
//                 ? const Color(0x66E53935)
//                 : kBorder,
//             width: 0.5,
//           ),
//           borderRadius: BorderRadius.circular(7),
//         ),
//         child: Text(
//           tag,
//           style: TextStyle(
//             fontSize: 12,
//             color: isActive ? kDarkRed : kTextSecondary,
//             fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
//           ),
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildContentDetailsSection() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionLabel('CONTENT DETAILS'),
//           const SizedBox(height: 14),
//           _buildFieldLabel('Lesson title', required: true),
//           const SizedBox(height: 6),
//           TextFormField(
//             controller: _titleController,
//             maxLength: 80,
//             decoration: _inputDecoration(
//               hint: 'e.g. Introduction to Quadratic Equations',
//               prefixIcon: const Icon(Icons.title_rounded,
//                   size: 18, color: kTextTertiary),
//             ),
//             buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
//             null,
//             validator: (v) =>
//             v == null || v.isEmpty ? 'Lesson title is required' : null,
//           ),
//           const SizedBox(height: 14),
//           _buildFieldLabel('Description'),
//           const SizedBox(height: 6),
//           TextFormField(
//             controller: _descriptionController,
//             maxLines: 4,
//             maxLength: 300,
//             onChanged: (v) => setState(() => _descCharCount = v.length),
//             decoration: _inputDecoration(
//               hint:
//               'Briefly describe what students will learn in this clip...',
//             ),
//             buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
//             null,
//           ),
//           const SizedBox(height: 4),
//           Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               '$_descCharCount / 300',
//               style: const TextStyle(fontSize: 11, color: kTextTertiary),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildActionsSection() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: const BoxDecoration(
//         color: kBg,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(16),
//           bottomRight: Radius.circular(16),
//         ),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.shield_outlined, size: 14, color: kTextTertiary),
//           const SizedBox(width: 6),
//           RichText(
//             text: const TextSpan(
//               style: TextStyle(fontSize: 12, color: kTextTertiary),
//               children: [
//                 TextSpan(text: 'Fields marked '),
//                 TextSpan(
//                     text: '*',
//                     style: TextStyle(color: kRed, fontWeight: FontWeight.w700)),
//                 TextSpan(text: ' are required'),
//               ],
//             ),
//           ),
//           const Spacer(),
//           _buildGhostButton(
//             label: 'Save draft',
//             icon: Icons.bookmark_border_rounded,
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Draft saved')),
//               );
//             },
//           ),
//           const SizedBox(width: 8),
//           _buildPrimaryButton(
//             label: 'Publish lesson',
//             icon: Icons.check_circle_outline_rounded,
//             onPressed: () {
//               if (_formKey.currentState!.validate()) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Lesson published successfully!'),
//                     backgroundColor: Color(0xFF2E7D32),
//                   ),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGhostButton({
//     required String label,
//     required IconData icon,
//     required VoidCallback onPressed,
//   }) {
//     return OutlinedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(icon, size: 16),
//       label: Text(label),
//       style: OutlinedButton.styleFrom(
//         foregroundColor: kTextSecondary,
//         side: const BorderSide(color: kBorder, width: 0.5),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         textStyle:
//         const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }
//
//   Widget _buildPrimaryButton({
//     required String label,
//     required IconData icon,
//     required VoidCallback onPressed,
//   }) {
//     return ElevatedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(icon, size: 16),
//       label: Text(label),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: kRed,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//         textStyle:
//         const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }
//
//
//   Widget _buildFieldLabel(String label, {bool required = false}) {
//     return Row(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             color: kTextSecondary,
//           ),
//         ),
//         if (required) ...[
//           const SizedBox(width: 3),
//           const Text('*',
//               style: TextStyle(
//                   color: kRed, fontSize: 13, fontWeight: FontWeight.w700)),
//         ],
//       ],
//     );
//   }
//
//   InputDecoration _inputDecoration({
//     required String hint,
//     Widget? prefixIcon,
//   }) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(fontSize: 13, color: kTextTertiary),
//       prefixIcon: prefixIcon,
//       prefixIconConstraints:
//       const BoxConstraints(minWidth: 40, minHeight: 40),
//       filled: true,
//       fillColor: const Color(0xFFFAFAFA),
//       contentPadding:
//       const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: kBorder, width: 0.5),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: kBorder, width: 0.5),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: kRed, width: 1.5),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Colors.red, width: 1),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Colors.red, width: 1.5),
//       ),
//     );
//   }
// }