import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Exit extends StatefulWidget {
  const Exit({super.key});

  @override
  ExitState createState() => ExitState();
}

class ExitState extends State<Exit> {


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 100,
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildText('Kilépés', 24, FontWeight.bold),
            const SizedBox(height: 16),
            _buildText('Biztosan ki szeretne lépni?', 20),
            const SizedBox(height: 30),
            _buildText('A visszalépéshez válasszon a lenti menüből', 12),
            const SizedBox(height: 20),
            _buildExitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String text, double fontSize, [FontWeight? fontWeight]) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildExitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextButton(
          child: const Text(
            'Kilépés   ',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
      ],
    );
  }
}