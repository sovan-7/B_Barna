import 'package:bbarna/banners/model/banners_model.dart';
import 'package:bbarna/banners/screen/add_banner.dart';
import 'package:bbarna/banners/viewModel/banners_viewmodel.dart';
import 'package:bbarna/banners/widgets/banner_card.dart';
import 'package:bbarna/core/widgets/add_widget.dart';
import 'package:bbarna/core/widgets/remove_alert.dart';
import 'package:bbarna/resources/app_tokens.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The banner grid.
///
/// The grid used to be a hardcoded five columns whatever the window was —
/// five tiles across a phone and five across a 27" monitor. It is sized by
/// available width now, and the tiles keep a banner's own 16:9 shape.
class BannerList extends StatefulWidget {
  const BannerList({super.key});

  @override
  State<BannerList> createState() => _BannerListState();
}

class _BannerListState extends State<BannerList> {
  /// Tiles stop growing past this; a wider window gets another column.
  static const double _tileMinWidth = 300;

  @override
  void initState() {
    super.initState();
    // Deferred to after the first frame: this screen is mounted from
    // Sidebar's `screenList[selectedIndex]` *during* a build, and the fetch
    // notifies synchronously. Calling it straight from initState marked the
    // Consumer dirty mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<BannersViewModel>(context, listen: false).getBannerList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTokens.canvas,
      child: Consumer<BannersViewModel>(
          builder: (context, bannersViewModel, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(bannersViewModel),
              const SizedBox(height: AppTokens.gapLg),
              Expanded(
                child: bannersViewModel.isLoading
                    ? const _SkeletonGrid(tileMinWidth: _tileMinWidth)
                    : bannersViewModel.bannersList.isEmpty
                        ? _EmptyState(onAdd: () => _openAdd(bannersViewModel))
                        : _grid(bannersViewModel),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _header(BannersViewModel bannersViewModel) {
    final int count = bannersViewModel.bannersList.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Flexible(
                    child: Text("Banners",
                        overflow: TextOverflow.ellipsis,
                        style: AppTokens.pageTitle),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTokens.surface,
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusPill),
                      border: Border.all(color: AppTokens.hairline),
                    ),
                    child: Text("$count",
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTokens.inkMuted)),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              const Text(
                "Shown in the app's home carousel, in this order.",
                style: AppTokens.pageSubtitle,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppTokens.gapMd),
        AddWidget(
          title: "NEW BANNER",
          addCall: () => _openAdd(bannersViewModel),
        ),
      ],
    );
  }

  void _openAdd(BannersViewModel bannersViewModel) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBanner()),
    ).whenComplete(() => bannersViewModel.getBannerList());
  }

  Widget _grid(BannersViewModel bannersViewModel) {
    final List<BannersModel> bannersList = bannersViewModel.bannersList;

    return LayoutBuilder(builder: (context, constraints) {
      final int columns = columnsFor(constraints.maxWidth, _tileMinWidth);
      final double tileWidth = columns == 1
          ? constraints.maxWidth
          : (constraints.maxWidth - AppTokens.gapMd * (columns - 1)) / columns;

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppTokens.gapMd),
        child: Wrap(
          spacing: AppTokens.gapMd,
          runSpacing: AppTokens.gapMd,
          children: [
            for (int i = 0; i < bannersList.length; i++)
              SizedBox(
                width: tileWidth,
                child: BannerCard(
                  key: ValueKey(bannersList[i].docId),
                  banner: bannersList[i],
                  position: i + 1,
                  onDelete: () => _confirmDelete(bannersViewModel, i),
                ),
              ),
          ],
        ),
      );
    });
  }

  /// Captures the doc id up front rather than reading
  /// `bannersList[index]` again inside the async callback — by the time the
  /// user confirms, a refresh may have reordered the list under it.
  void _confirmDelete(BannersViewModel bannersViewModel, int index) {
    final String docId = bannersViewModel.bannersList[index].docId;

    RemoveAlert.showRemoveAlert(
      title: "Banner ${index + 1}",
      description: "Are you sure want to delete ?",
      onPressYes: () async {
        // RemoveAlert never closes itself, and it is dismissed before the
        // delete so there is no second route in flight for the refresh to
        // race with. The grid's own skeletons cover the wait.
        Navigator.pop(navigatorKey.currentContext!);
        final bool success = await bannersViewModel.deleteBanner(docId);
        if (success) {
          Helper.showSnackBarMessage(
              msg: "Banner deleted successfully", isSuccess: false);
          await bannersViewModel.getBannerList();
        }
      },
    );
  }
}

/// Columns that fit [width] at [tileMinWidth] apiece, capped so tiles never
/// get so wide that four banners fill a whole monitor.
int columnsFor(double width, double tileMinWidth) =>
    (width / tileMinWidth).floor().clamp(1, 5);

class _SkeletonGrid extends StatelessWidget {
  final double tileMinWidth;
  const _SkeletonGrid({required this.tileMinWidth});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final int columns = columnsFor(constraints.maxWidth, tileMinWidth);
      final double tileWidth = columns == 1
          ? constraints.maxWidth
          : (constraints.maxWidth - AppTokens.gapMd * (columns - 1)) / columns;

      return Wrap(
        spacing: AppTokens.gapMd,
        runSpacing: AppTokens.gapMd,
        children: [
          // Two rows' worth — enough to read as "loading", not so many that
          // the page scrolls before there is anything to scroll.
          for (int i = 0; i < columns * 2; i++)
            SizedBox(
              width: tileWidth,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    border: Border.all(color: AppTokens.hairline),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: const BoxDecoration(
                  color: AppTokens.surfaceMuted, shape: BoxShape.circle),
              child: const Icon(Icons.image_outlined,
                  size: 28, color: AppTokens.inkFaint),
            ),
            const SizedBox(height: AppTokens.gapMd),
            const Text("No banners yet",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.ink)),
            const SizedBox(height: 5),
            const SizedBox(
              width: 320,
              child: Text(
                "Banners you upload appear on the app's home screen.",
                textAlign: TextAlign.center,
                style: AppTokens.pageSubtitle,
              ),
            ),
            const SizedBox(height: AppTokens.gapLg),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.upload_outlined, size: 16),
              label: const Text("Upload a banner"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTokens.ink,
                side: const BorderSide(color: AppTokens.hairline),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTokens.radiusMd)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
