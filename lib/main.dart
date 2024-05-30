import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
                color: Colors.grey
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
  int maxTime = 60 * 20;
  int second = 0;
  int base = 1;
  bool modifySec = false;
  bool isStarted = false;
  bool isRunning = false;
  bool isFinished = false;
  Timer? timer;
  Timer? flashTimer;
  IconData icon = Icons.play_arrow;
  DateTime? end;

  ScrollController minController = ScrollController();

  @override
  void initState() {
    Wakelock.enable();
    super.initState();

    second = maxTime;
    minController.addListener(_scrollDown);
  }

  void _scrollDown() {
    // if(minController.position.) {
    //   increaseTime();
    // }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Wakelock.disable();
    minController.removeListener(_scrollDown);
    super.dispose();
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

  void setBase(base) {
    setState(() {
      this.base = base;
    });
  }

  void setModifySec(modifySec) {
    setState(() {
      this.modifySec = modifySec;
    });
  }

  void decreaseTime() {
    print('decreased');
    if(!isRunning) {
      setState(() {
        maxTime = max(maxTime - (base * (modifySec ? 1 : 60)), 0);
        second = max(second - (base * (modifySec ? 1 : 60)), 0);
      });
    }
  }

  void increaseTime() {
    print('increased');
    if(!isRunning) {
      setState(() {
        maxTime = maxTime + (base * (modifySec ? 1 : 60));
        second = second + (base * (modifySec ? 1 : 60));
      });
    }
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
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 180.0),
                        child: Text(
                          'Flash Timer',
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        child: Text(
                          '${(second/60).truncate()} m ${(second%60).round()}',
                          style: const TextStyle(
                            fontSize: 80,
                            color: Colors.grey,
                          ),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                decreaseTime();
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.remove,
                                    size: 20),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                handlerButtonPressed();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Icon(icon,
                                  size: 40),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                increaseTime();
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.add,
                                    size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => {
                        setModifySec(true)
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(modifySec ? Colors.black : Color.fromRGBO(55, 55, 55, 1)),
                      ),
                      child: Text('sec')),
                    ElevatedButton(
                      onPressed: () => {
                        setModifySec(false)
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(!modifySec ? Colors.black : Color.fromRGBO(55, 55, 55, 1)),
                      ),
                      child: Text('min')),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => {
                        setBase(1)
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(base == 1 ? Colors.black : Color.fromRGBO(55, 55, 55, 1)),
                      ),
                      child: Text('1')),
                    ElevatedButton(
                      onPressed: () => {
                        setBase(2)
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(base == 2 ? Colors.black : Color.fromRGBO(55, 55, 55, 1)),
                      ),
                      child: Text('2')),
                    ElevatedButton(
                      onPressed: () => {
                        setBase(5)
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(base == 5 ? Colors.black : Color.fromRGBO(55, 55, 55, 1)),
                      ),
                      child: Text('5')),
                    ElevatedButton(
                      onPressed: () => {
                        setBase(10)
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(base == 10 ? Colors.black : Color.fromRGBO(55, 55, 55, 1)),
                      ),
                      child: Text('10')),
                    ElevatedButton(
                      onPressed: () => {
                        setBase(15)
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(base == 15 ? Colors.black : Color.fromRGBO(55, 55, 55, 1)),
                      ),
                      child: Text('15')),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}