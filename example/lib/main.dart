import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:gesture_debouncer/gesture_debouncer.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      toastTheme: ToastThemeData(
        background: Colors.indigo,
        textColor: Colors.white,
      ),
      child: MaterialApp(
        title: 'Gesture Debouncer',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          primaryColor: Colors.indigo,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool liked = false;
  double iconSize = 45;

  Widget _getIconWidget(onPressed) {
    return IconButton(
      icon: Icon(
        liked ? FontAwesome.heart : FontAwesome.heart_empty,
      ),
      iconSize: iconSize,
      color: liked ? Colors.red : Colors.grey,
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Gesture Debouncer",
          style: TextStyle(fontSize: 15),
        ),
      ),
      body: Center(
        child: GestureDebouncer(
          cooldownAfterExecution: const Duration(seconds: 2),
          cooldownBuilder: (BuildContext ctx, _) {
            return Stack(
              alignment: AlignmentDirectional.center,
              children: [
                _getIconWidget(() {
                  if (liked) {
                    toast("You have recently liked this");
                  } else {
                    toast("You have recently unliked this");
                  }
                }),
                IgnorePointer(
                  // Used so that main icon gets the click event
                  child: Icon(
                    Icons.lock_outline,
                    color: liked ? Colors.white : Colors.grey,
                    size: iconSize / 3,
                  ),
                ),
              ],
            );
          },
          onError: (e) {
            log(e.toString());
          },
          builder: (BuildContext ctx, Future<void> Function()? onGesture) {
            return _getIconWidget(onGesture);
          },
          onGesture: () async {
            setState(() {
              liked = !liked;
            });
            await Future.delayed(const Duration(seconds: 2), () {});
          },
        ),
      ),
    );
  }
}
