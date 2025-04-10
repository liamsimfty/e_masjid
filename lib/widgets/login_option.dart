import 'package:flutter/material.dart';

class LoginOption extends StatelessWidget {
  const LoginOption({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        BuildButton(
          iconImage: Image(
            height: 20,
            width: 20,
            image: AssetImage('assets/masjid.png'),
          ),
          textButton: 'Facebook',
        ),
        BuildButton(
          iconImage: Image(
            height: 20,
            width: 20,
            image: AssetImage('assets/google.png'),
          ),
          textButton: 'Google',
        ),
      ],
    );
  }
}

class BuildButton extends StatelessWidget {
  final Image iconImage;
  final String textButton;
  const BuildButton({Key? key, required this.iconImage, required this.textButton}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Container(
      height: mediaQuery.height * 0.06,
      width: mediaQuery.width * 0.36,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: (Colors.grey[300])!)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconImage,
          const SizedBox(
            width: 5,
          ),
          Text(textButton),
        ],
      ),
    );
  }
}