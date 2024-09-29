import 'package:bible_chat/Global/colors.dart';
import 'package:bible_chat/Global/styles.dart';
import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  const SearchBox(
      {super.key, required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
        ),
        child: Center(
          child: TextField(
            focusNode: focusNode,
            controller: controller,
            maxLines: null,
            style: k15Medium,
            decoration: InputDecoration.collapsed(
              hintText: "Ask a question",
              hintStyle: k15Medium.copyWith(
                color: kBlack.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
