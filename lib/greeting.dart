import 'package:flutter/cupertino.dart';
import 'package:hardverinfo/variables.dart';

class Greeting extends StatefulWidget {
  const Greeting({super.key});

  @override
  GreetingState createState() => GreetingState();
}

class GreetingState extends State<Greeting> with SingleTickerProviderStateMixin {
  Variables variables = Variables();

  @override
  void initState() {
    super.initState();


    variables.setAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    variables.setAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(variables.getGreetAnimationController);

    variables.setDelayedAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: variables.getGreetAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    variables.getGreetAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: variables.getGreetAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Üdvözöljük!\n\n",
              style: TextStyle(
                fontSize: 40,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            AnimatedBuilder(
              animation: variables.getDelayedAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: variables.getDelayedAnimation.value,
                  child: child,
                );
              },
              child: const Text(
                "Kérjük a lenti menüből válasszon!",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    variables.getGreetAnimationController.dispose();
    super.dispose();
  }
}