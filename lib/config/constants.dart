import 'package:flutter/material.dart';

ThemeData theme(){
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'sans-serif',
    textTheme: textTheme(),
  );
}
// const kPrimaryColor = Color(0xFF3871c1);
const kSecondaryColor = Color(0xFF59706F);
const kDarkGreyColor = Color(0xFFEEEEEE);
// const kWhiteColor = Color(0xFFFFFFFF);
// const kZambeziColor = Color(0xFF5B5B5B);
const kBlackColor = Color(0xFF272726);
const kTextFieldColor = Color(0xFF979797);
const kDrawerBackgroundColor = Color(0xFFF5F5F5); // A light grey for drawer
// const Color kInputTextColor = Color(0xFF333333); // Example dark grey for input text
const Color kPrimaryColor = Color(0xFF00796B); // Example: Teal
const Color kZambeziColor = Color(0xFF585858); // Example
const Color kWhiteColor = Colors.white;
final TextStyle subTitle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kZambeziColor);
final TextStyle textButton = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kPrimaryColor);
const EdgeInsets kDefaultPadding = EdgeInsets.all(20.0);
const Color kPrimaryColorDark = Color(0xFF00796B);
const kInputTextColor1 = Color(0xFF3A3A3A);
const kInputTextColor = Color(0xFF333333);
// const kDefaultPadding = EdgeInsets.symmetric(horizontal: 30);

TextStyle titleText = const TextStyle(
  color: Colors.white,
  fontSize: 35,
  fontWeight: FontWeight.w700,
  height: 1.2,
  fontFamily: 'RobotoMono',
);
// fontWeight: FontWeight.w200);

// TextStyle subTitle = const TextStyle(
//     color: kSecondaryColor, fontSize: 18, fontWeight: FontWeight.w500);

// TextStyle textButton = const TextStyle(
//   color: kPrimaryColor,
//   fontSize: 18,
//   fontWeight: FontWeight.w700,
// );



// method text theme
TextTheme textTheme(){
return const TextTheme(
    displayLarge: TextStyle(
      color: Colors.black,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodyLarge: TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      color: Colors.black,
      fontSize: 10,
      fontWeight: FontWeight.normal,
    ),
  );
}