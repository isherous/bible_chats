import 'package:bible_chat/Global/colors.dart';
import 'package:bible_chat/Global/styles.dart';
import 'package:bible_chat/Providers/main-provider.dart';
import 'package:bible_chat/Widgets/search-box.dart';
import 'package:bible_chat/Widgets/search-button.dart';
import 'package:bible_chat/Widgets/sized-widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import '../Services/firebase-services.dart';
import '../Services/gemini-services.dart';
import '../Services/image-generation-services.dart';
import '../Services/pinecone-services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = TextEditingController();
  final geminiServices = GeminiServices();
  final pinconeServices = PineConeServices();
  final imageServices = ImageGenerationServices();
  final firebaseServices = FirebaseServices();
  String? message;

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.watch<MainProvider>();
    double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: kGreen,
      body: ModalProgressHUD(
        inAsyncCall: mainProvider.showProgress,
        progressIndicator: const SpinKitCubeGrid(color: kWhite),
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 960),
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kHeight24,

                    ///Logo
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'BIBLE ',
                            style: k32CormorantBold.copyWith(color: kWhite),
                          ),
                          TextSpan(
                            text: 'CHAT',
                            style: k32CormorantLight.copyWith(color: kWhite),
                          )
                        ],
                      ),
                    ),

                    kHeight12,

                    const Expanded(child: kEmptyWidget),

                    ///Question and Answer
                    if (mainProvider.answer != null)
                      Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: height * .5,
                            // maxWidth: 900,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ///Question
                                Text(
                                  mainProvider.question ?? "",
                                  style: k21CormorantBold,
                                ),

                                kHeight16,

                                ///Answer
                                Text(
                                  mainProvider.answer ?? "",
                                  style: k15Medium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    kHeight36,

                    const Expanded(child: kEmptyWidget),

                    kHeight24,

                    // ///Suggestions
                    // SizedBox(
                    //   height: 56,
                    //   child: ListView.separated(
                    //     shrinkWrap: true,
                    //     scrollDirection: Axis.horizontal,
                    //     itemCount: 5,
                    //     itemBuilder: (context, index) {
                    //       return _SingleSuggestion();
                    //     },
                    //     separatorBuilder: (context, index) {
                    //       return kWidth12;
                    //     },
                    //   ),
                    // ),
                    //
                    // kHeight16,

                    ///Question Field and Search Button
                    SizedBox(
                      height: 70,
                      child: Row(
                        children: [
                          SearchBox(controller: controller),
                          SearchButton(controller: controller),
                        ],
                      ),
                    ),
                    kHeight36,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SingleSuggestion extends StatelessWidget {
  const _SingleSuggestion({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kWhite.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "Who was David?",
          style: k15Medium.copyWith(color: kWhite),
        ),
      ),
    );
  }
}
