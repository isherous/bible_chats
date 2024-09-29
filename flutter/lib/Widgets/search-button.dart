import 'package:bible_chat/Global/colors.dart';
import 'package:bible_chat/Global/styles.dart';
import 'package:bible_chat/Services/search-services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/main-provider.dart';

final _searchServices = SearchServices();

class SearchButton extends StatelessWidget {
  const SearchButton({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.watch<MainProvider>();

    return InkWell(
      onTap: () async {
        String query = controller.text;

        print("Start");

        if (query.isEmpty) {
          return;
        }
        controller.clear();
        mainProvider.changeShowProgress(true);
        String answer = await _searchServices.fullSearch(query: query);
        mainProvider.changeShowProgress(false);
        mainProvider.changeAnswer(answer);
      },
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          color: kPeach,
          // color: kGreen,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Center(
          child: Text(
            "Search",
            style: k15Medium.copyWith(height: 1),
          ),
        ),
      ),
    );
  }
}
