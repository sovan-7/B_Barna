import 'package:flutter/material.dart';
import 'package:bbarna/resources/app_colors.dart';

class SidebarWidget extends StatelessWidget {
  final IconData iconData;
  final String itemText;
  final bool isSelected;
  const SidebarWidget(
      {required this.iconData,
      required this.itemText,
      required this.isSelected,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 5,
      ),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                width: 1, color: AppColorsInApp.colorBlack1.withValues(alpha: .5))),
        color: isSelected ? AppColorsInApp.colorOrange : Colors.transparent,
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 22,
            color: AppColorsInApp.colorBlack1,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                itemText,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: AppColorsInApp.colorBlack1),
              ),
            ),
          ),
          const Icon(
            Icons.arrow_right,
            color: AppColorsInApp.colorBlack1,
            size: 20,
          )
        ],
      ),
    );
  }
}
