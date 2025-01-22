import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hardverinfo/variables.dart';

import 'homepage.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> with SingleTickerProviderStateMixin {
  final Variables variables = Variables();

  @override
  void initState() {
    super.initState();

    variables.setAppAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    variables.setAppColorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          weight: 33.3,
          tween: ColorTween(
            begin: Colors.lightBlueAccent,
            end: Colors.lightGreenAccent,
          ),
        ),
        TweenSequenceItem(
          weight: 33.3,
          tween: ColorTween(
            begin: Colors.redAccent,
            end: Colors.yellowAccent,
          ),
        ),
        TweenSequenceItem(
          weight: 33.3,
          tween: ColorTween(
            begin: Colors.orangeAccent,
            end: Colors.purpleAccent,
          ),
        ),
      ],
    ).animate(variables.getAppAnimationController);
  }

  @override
  void dispose() {
    variables.getAppAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    return AnimatedBuilder(
      animation: variables.getAppAnimationController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'HI',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: Scaffold(
            body: AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    variables.getAppColorAnimation.value!,
                    Colors.white,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
              child: const HomePage(title: 'Hardver-Info'),
            ),
          ),
        );
      },
    );
  }
}