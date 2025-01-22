import 'package:flutter/material.dart';
import 'package:hardverinfo/variables.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  AboutState createState() => AboutState();
}

class AboutState extends State<About> {
  Variables variables = Variables();

  void showSnackBar() {
    final snackBar = SnackBar(
      content: Text(variables.getSnackMessage),
      duration: const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Névjegy'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                  showSnackBar();
              },
              child: const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile_image.png'),
              ),
            ),
            const SizedBox(height: 20),
            _buildText('Garamszegi Márton a. Csucsu', 24, Colors.black, FontWeight.bold),
            _buildText('Végzős mérnökinformatikus hallgató', 18, Colors.grey),
            const SizedBox(height: 20),
            _buildText('~Csuccsú, megy a flex', 16),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String text, double fontSize,
      [Color? color, FontWeight? fontWeight]) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        fontFamily: "Poppins",
      ),
      textAlign: TextAlign.center,
    );
  }
}