import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/core/widgets/sidebar_widget.dart';

// NOTE on scope: `Sidebar` and `ExtraSideBar` each hold their own
// independent, hand-synchronized `drawerItems`/`iconList` arrays (see
// .claude/peer/PROJECT_KNOWLEDGE.md). Ideally this test would pump both and
// compare them directly. In practice, pumping the real `Sidebar` widget
// mounts `screenList[selectedIndex]` (e.g. `BannerList`) eagerly, whose
// `initState` lazily constructs its ChangeNotifierProvider's ViewModel ->
// Repo -> `FirebaseFirestore.instance`, which throws synchronously with no
// Firebase test app initialized anywhere in this codebase. That's a
// pre-existing coupling, not something this feature introduces or should
// take on. So this test covers what's safely verifiable in isolation
// (ExtraSideBar contains "TEACHERS" at the expected index/icon); the
// Sidebar-side of the invariant is covered by manual QA (see the plan's
// Verification section: check the Teachers entry at both >900px and
// <900px window widths).
void main() {
  testWidgets(
      'ExtraSideBar renders a "TEACHERS" entry at index 11 with the people icon',
      (tester) async {
    // Default test surface is too short for ListView.builder to lay out
    // all 12 items (only the ones that fit in the viewport get built).
    // Widen it so every item is actually mounted and findable.
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ExtraSideBar(sidebarIndex: 0)),
    ));

    final widgets =
        tester.widgetList<SidebarWidget>(find.byType(SidebarWidget)).toList();

    expect(widgets, hasLength(12),
        reason: '11 existing sections + the new Teachers section');
    expect(widgets[11].itemText, 'TEACHERS');
    expect(widgets[11].iconData, Icons.people_alt_outlined);
  });
}
