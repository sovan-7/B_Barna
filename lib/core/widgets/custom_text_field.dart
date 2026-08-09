// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:bbarna/resources/app_colors.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  String? title;
  String? labelText;
  bool? isBorderRadius;
  TextEditingController? textEditingController;
  TextInputType textInputType;
  bool passwordVisible = false;
  final Function? onIconPress;
  FocusNode ?focusNode;
  bool enabled;
  CustomTextField(
      {required this.labelText,
      required this.title,
      this.isBorderRadius = true,
      this.textEditingController,
      this.textInputType = TextInputType.text,
      this.passwordVisible = false,
      this.onIconPress,
      this.focusNode,
      this.enabled = true,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != "")
          Text(
            title!,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColorsInApp.colorGrey),
          ),
        Container(
          width: 350,
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: isBorderRadius!
                ? BorderRadius.circular(10)
                : BorderRadius.circular(0),
            color: AppColorsInApp.colorWhite,
          ),
          child: TextField(
            obscureText: passwordVisible,
            enabled: enabled,
           focusNode:focusNode ,
            controller: textEditingController,
            keyboardType: textInputType,
            inputFormatters: textInputType == TextInputType.number
                ? [FilteringTextInputFormatter.digitsOnly]
                : [],
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: AppColorsInApp.colorWhite,
              labelText: labelText,
              labelStyle: const TextStyle(
                  color: AppColorsInApp.colorGrey, fontSize: 12),
              contentPadding: const EdgeInsets.only(
                left: 15,
              ),
              suffixIcon: labelText == "password"
                  ? IconButton(
                      icon: Icon(passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        onIconPress!();
                      },
                    )
                  : null,
              alignLabelWithHint: false,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}
