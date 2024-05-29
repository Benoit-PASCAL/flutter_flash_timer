import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

// my phone screen : 922 x 414

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flash Timer',
      theme: ThemeData(
        fontFamily: 'ClashDisplay',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(55, 55, 55, 1)),
            foregroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(186, 186, 186, 1)),
            textStyle: MaterialStateProperty.all<TextStyle>(
              const TextStyle(
                // fontFamily: 'inherit',
              )
            )
          )
        ),
        colorScheme: ColorScheme.fromSeed(
          background: Colors.black,
          seedColor: Colors.blueGrey
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double bg_opacity = 0.0;
  bool increaseOpacity = true;
  static const maxTime = 60 * 20;
  int second = maxTime;
  bool isStarted = false;
  bool isRunning = false;
  bool isFinished = false;
  Timer? timer;
  Timer? flashTimer;
  IconData icon = Icons.play_arrow;
  DateTime? end;

  @override
  void initState() {
    Wakelock.enable();
    super.initState();
  }

  void handlerButtonPressed() {

    if(isFinished) {
      stopFlash();
      isFinished = false;
      isStarted = false;
      isRunning = false;
      setState(() {
        second = maxTime;
        icon = Icons.play_arrow;
        bg_opacity = 0.0;
      });
      return;
    }

    if(!isStarted) {
      isStarted = true;
      isRunning = true;
      setState(() {
        icon = Icons.pause;
      });
      resumeTimer();
      return;
    }

    if(isRunning) {
      isRunning = false;
      setState(() {
        icon = Icons.play_arrow;
      });
      pauseTimer();
      return;
    }

    if(!isRunning) {
      isRunning = true;
      setState(() {
        icon = Icons.pause;
      });
      resumeTimer();

      return;
    }
  }

  void resumeTimer() {
    setState(() {
      end = DateTime.now().add(Duration(seconds: second));
    });
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if(second == 0) {
        isFinished = true;
        timer?.cancel();
        isRunning = false;
        startFlash();
        setState(() {
          icon = Icons.change_circle;
        });
      } else {
        setState(() {
          second = end!.difference(DateTime.now()).inSeconds;
          // second = max(second - 1, 0);
        });
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
  }

  void startFlash() {
    flashTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
      setState(() {
        if(bg_opacity <= 0) {
          increaseOpacity = true;
        } else if(bg_opacity >= 1) {
          increaseOpacity = false;
        }
        if(increaseOpacity) {
          bg_opacity = min(bg_opacity + 0.1, 1);
        } else {
          bg_opacity = max(bg_opacity - 0.1, 0);
        }
      });
    });
  }

  void stopFlash() {
    flashTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(bg_opacity),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 120.0),
                    child: Text(
                      'Flash Timer',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Text(
                    '${(second/60).truncate()} m ${(second%60).round()}',
                    style: const TextStyle(
                      fontSize: 80,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${end ?? ''}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: ElevatedButton(
                      onPressed: () {
                        handlerButtonPressed();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Icon(icon,
                          size: 40),
                      ),
                    ),
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}