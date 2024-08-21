import 'package:flutter/cupertino.dart';

class ResidentCountWidget extends StatelessWidget {
  final int residentCount;

  const ResidentCountWidget({super.key, required this.residentCount});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
        child: Text(
          '$residentCount 세대',
          style: TextStyle(fontSize: 11.0),
        ),
      ),
    );
  }
}