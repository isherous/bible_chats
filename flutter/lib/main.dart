import 'package:bible_chat/Services/firebase-services.dart';
import 'package:bible_chat/services/gemini-services.dart';
import 'package:bible_chat/services/image-generation-services.dart';
import 'package:bible_chat/services/pinecone-services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'Global/colors.dart';
import 'firebase_options.dart';

///Firebase
final Future<FirebaseApp> _initialization =
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: kTransparent,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ///Analytics
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Container(color: Colors.amber);
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Bible Chat',
            navigatorObservers: <NavigatorObserver>[observer],
            home: const Home(),
          );
        }
        return Container();
      },
    );
  }
}

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

  bool showProgress = false;
  String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showProgress,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(message ?? ""),

                const SizedBox(height: 36),

                ///Question Field
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: "Ask a question"),
                ),
                const SizedBox(height: 12),

                ///Send Button
                TextButton(
                  child: const Text("Search"),
                  onPressed: () async {
                    String query = controller.text;

                    print("Start");

                    if (query.isEmpty) {
                      return;
                    }

                    ///Storing message to Firebase
                    firebaseServices.sendMessage(query);

                    controller.clear();

                    setState(() {
                      showProgress = true;
                    });

                    ///Getting Embeddings
                    List<double>? vectors =
                        await geminiServices.convertTextToEmbeddings(query);

                    if (vectors == null) {
                      setState(() {
                        message = "Could not convert text to embeddings";
                        showProgress = false;
                      });
                      return;
                    }

                    print("Text to Embeddings Done");

                    ///Vector Search
                    List<String>? versesList =
                        await pinconeServices.searchBible(vectors);

                    if (versesList == null) {
                      setState(() {
                        message = "Vector Search could not happen";
                        showProgress = false;
                      });
                      return;
                    }
                    print("Vector Search Done");

                    ///Getting the answer from the LLM
                    Map? responseFromGemini =
                        await geminiServices.getResponseFromGemini(
                      verses: versesList,
                      query: query,
                    );

                    print(responseFromGemini);

                    if (responseFromGemini == null) {
                      setState(() {
                        message = "Gemini LLM didn't return anything";
                        showProgress = false;
                      });
                      return;
                    }

                    bool status = responseFromGemini["status"];
                    String messageFromLLM = responseFromGemini["message"];

                    setState(() {
                      message = messageFromLLM;
                      showProgress = false;
                    });

                    // if (status) {
                    //   await imageServices.createImageWithLimeWire(
                    //       responseFromGemini["message"]);
                    // }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
