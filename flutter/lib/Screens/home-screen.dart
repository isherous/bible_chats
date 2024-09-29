import 'package:bible_chat/Global/asset-values.dart';
import 'package:bible_chat/Global/colors.dart';
import 'package:bible_chat/Global/styles.dart';
import 'package:bible_chat/Providers/main-provider.dart';
import 'package:bible_chat/Services/attribution-services.dart';
import 'package:bible_chat/Services/firebase-services.dart';
import 'package:bible_chat/Services/search-services.dart';
import 'package:bible_chat/Widgets/search-box.dart';
import 'package:bible_chat/Widgets/search-button.dart';
import 'package:bible_chat/Widgets/sized-widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

final _searchServices = SearchServices();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final attributionServices = AttributionServices();
  final firebaseServices = FirebaseServices();

  final controller = TextEditingController();
  String? message;

  late FocusNode _focusNode;

  ///Initializing the Focus Node for TextField
  ///to detect Enter and Shift+Enter on a Keyboard
  void initFocusNode() {
    _focusNode = FocusNode(
      onKeyEvent: (FocusNode node, KeyEvent evt) {
        bool isEnterPressed = evt.logicalKey.keyLabel == "Enter" ||
            evt.logicalKey.keyLabel == "Numpad Enter";

        bool isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

        ///Shift + Enter
        if (isShiftPressed && isEnterPressed) {
          if (evt is KeyDownEvent) {
            controller.text += '\n';
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        }

        ///Enter Only
        else if (!isShiftPressed && isEnterPressed) {
          if (evt is KeyDownEvent) {
            // messageController.clear();
            ///Send on Enter on Desktop
            if (attributionServices.isDesktop()) {
              searchFunction();
              // _searchServices.fullSearch(query: query)
            }

            ///Next Line on Mobile
            else {
              controller.text += '\n';
            }
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        }

        ///
        else {
          return KeyEventResult.ignored;
        }
      },
    );
  }

  ///Search Function for when the user hits submit on their keyboard
  Future<void> searchFunction() async {
    final mainProvider = Provider.of<MainProvider>(context, listen: false);
    String query = controller.text;

    mainProvider.changeQuestion(query);

    print("Start");
    controller.clear();
    mainProvider.changeShowProgress(true);
    String answer = await _searchServices.fullSearch(query: query);
    mainProvider.changeShowProgress(false);
    mainProvider.changeAnswer(answer);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///For Enter & Shift+Enter
    initFocusNode();

    ///Signing in User
    WidgetsBinding.instance.addPostFrameCallback((_) => signInUser());
  }

  Future<void> signInUser() async {
    String? userId = await firebaseServices.signInUser();
    if (userId != null) {
      await firebaseServices.storingUserInfo(userId);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kHeight16,

                  ///Logo and Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ///Cross
                      Image.asset(kCross),
                      kWidth4,

                      ///Bible Chat
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
                    ],
                  ),

                  kHeight12,

                  const Expanded(child: kEmptyWidget),

                  ///Question and Answer
                  if (mainProvider.answer != null)
                    Center(
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: height * .5,
                          maxWidth: 640,
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

                  ///Suggestions
                  SizedBox(
                    height: 56,
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: mainProvider.kSuggestions.length,
                      itemBuilder: (context, index) {
                        return _SingleSuggestion(
                          question: mainProvider.kSuggestions[index],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return kWidth12;
                      },
                    ),
                  ),

                  kHeight16,

                  ///Question Field and Search Button
                  SizedBox(
                    height: 70,
                    child: Row(
                      children: [
                        ///Question Field
                        SearchBox(
                          controller: controller,
                          focusNode: _focusNode,
                        ),

                        ///Search Button
                        SearchButton(controller: controller),
                      ],
                    ),
                  ),
                  kHeight16,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SingleSuggestion extends StatelessWidget {
  const _SingleSuggestion({required this.question});

  final String question;

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.watch<MainProvider>();

    return InkWell(
      onTap: () async {
        mainProvider.removeSuggestFromList(question);
        mainProvider.changeQuestion(question);
        mainProvider.changeShowProgress(true);
        String answer = await _searchServices.fullSearch(
          query: question,
          isSuggestion: true,
        );
        mainProvider.changeShowProgress(false);
        mainProvider.changeAnswer(answer);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: kWhite.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            question,
            style: k15Medium.copyWith(color: kWhite),
          ),
        ),
      ),
    );
  }
}
