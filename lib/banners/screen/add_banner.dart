import 'dart:typed_data';

import 'package:bbarna/banners/model/banners_model.dart';
import 'package:bbarna/banners/viewModel/banners_viewmodel.dart';
import 'package:bbarna/core/widgets/app_header.dart';
import 'package:bbarna/core/widgets/choose_image.dart';
import 'package:bbarna/core/widgets/sidebar.dart';
import 'package:bbarna/core/widgets/loader_dialog.dart';
import 'package:bbarna/core/widgets/save_button.dart';
import 'package:bbarna/utils/helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddBanner extends StatefulWidget {
  const AddBanner({super.key});

  @override
  State<AddBanner> createState() => _AddBannerState();
}

class _AddBannerState extends State<AddBanner> {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  Uint8List? selectedImageBytes;
  String imageName = "";
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: key,
        body: PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            // handle back press
          },
          canPop: true,
          child: Column(children: [
            AppHeader(
              onTapIcon: () {
                key.currentState?.openDrawer();
              },
            ),
            Expanded(
              child: Row(children: [
                if (width > 900)
                  const Expanded(
                      child: ExtraSideBar(
                    sidebarIndex: 0,
                  )),
                Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selectedImageBytes != null)
                          Container(
                            height: 200,
                            width: 180,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: MemoryImage(selectedImageBytes!),
                                  fit: BoxFit.fill,
                                )),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: ChooseImage(
                            onSelectImage: () async {
                              var picked = await FilePicker.platform.pickFiles(
                                type: FileType.image,
                              );

                              if (picked != null) {
                                setState(() {
                                  selectedImageBytes = picked.files.first.bytes;
                                  imageName = picked.files.first.name;
                                });
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: SaveButton(onPRess: () {
                            if (selectedImageBytes != null) {
                              LoaderDialogs.showLoadingDialog();
                              BannersModel bannersModel =
                                  BannersModel(bannerImage: "");
                              BannersViewModel bannersViewModel =
                                  Provider.of<BannersViewModel>(context,
                                      listen: false);
                              bannersViewModel
                                  .addBanner(bannersModel)
                                  .then((value) {
                                bannersViewModel
                                    .uploadBannerImage(
                                        selectedImageBytes!, value.id)
                                    .then((value) {
                                  Navigator.pop(context);
                                  Helper.showSnackBarMessage(
                                      msg: "Banners uploaded successfully",
                                      isSuccess: true);
                                  Navigator.pop(context);
                                });
                              });
                            }
                          }),
                        ),
                      ],
                    ))
              ]),
            )
          ]),
        ),
        drawer: width < 900
            ? const Drawer(
                child: ExtraSideBar(sidebarIndex: 0),
              )
            : null);
  }
}
