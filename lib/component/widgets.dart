// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Widgets {
  static Text pageTitle(
    String title, {
    int? maxLines,
  }) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16.0),
      maxLines: maxLines ?? 1,
    );
  }

  static Widget imageNetwork(
    String? imageUrl,
    double height,
    IconData errorIcon,
  ) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: height,
        height: height,
        fit: BoxFit.fitHeight,
        errorBuilder: (context, error, stackTrace) {
          return Icon(errorIcon, size: height);
        },
      );
    } else {
      return Icon(errorIcon, size: height);
    }
  }

  static Widget textField(
    TextEditingController controller,
    String labelText, {
    int? maxLines,
    FocusNode? focusNode,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        // suffix: Container(
        //   width: 50,
        //   height: 10,
        //   color: Colors.blue,
        //   child: Text("ssdsdds"),
        // ),
        // suffixIconColor: Colors.red,
        suffixIcon: IconButton(
          color: Colors.white,
          onPressed: () {
            print("Cliekceds");
          },
          icon: Icon(Icons.arrow_upward),
        ),
        //  InkWell(
        //   child: Container(
        //     decoration: BoxDecoration(
        //       shape: BoxShape.circle,
        //       color: Color(0xFFFF006A),
        //     ),
        //     padding: EdgeInsets.all(4.0),
        //     child: CircleAvatar(
        //       backgroundColor: Colors.transparent,
        //       child: IconButton(
        //         color: Colors.white,
        //         onPressed: () {},
        //         icon: Icon(Icons.arrow_upward),
        //       ),
        //     ),
        //   ),
        // ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: Colors.purple),
        ),
        hintText: labelText,
      ),
      maxLines: maxLines ?? 1,
      focusNode: focusNode,
    );
  }

  static Widget textFieldForNum({
    required TextEditingController controller,
    required String labelText,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
        labelText: labelText,
        contentPadding: const EdgeInsets.all(8.0),
      ),
      onChanged: onChanged,
    );
  }
}
