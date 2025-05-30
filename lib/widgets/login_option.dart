import 'package:flutter/material.dart';

class LoginOption extends StatelessWidget {
  final Function(String)? onError;
  
  const LoginOption({
    super.key,
    this.onError,
  });

  void _handleSocialLoginError(BuildContext context, String error) {
    String message;
    switch (error) {
      case 'account-exists-with-different-credential':
        message = 'Akaun dengan emel ini telah wujud dengan kaedah log masuk yang berbeza';
        break;
      case 'invalid-credential':
        message = 'Kredensial tidak sah';
        break;
      case 'operation-not-allowed':
        message = 'Kaedah log masuk ini tidak dibenarkan';
        break;
      case 'user-disabled':
        message = 'Akaun telah dinyahaktifkan';
        break;
      case 'user-not-found':
        message = 'Pengguna tidak dijumpai';
        break;
      case 'network-request-failed':
        message = 'Ralat rangkaian. Sila periksa sambungan internet anda';
        break;
      default:
        message = 'Ralat semasa log masuk. Sila cuba lagi';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    
    if (onError != null) {
      onError!(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        BuildButton(
          iconImage: const Image(
            height: 20,
            width: 20,
            image: AssetImage('assets/masjid.png'),
          ),
          textButton: 'Facebook',
          onPressed: () {
            // Add your Facebook login logic here
            // If error occurs:
            // _handleSocialLoginError(context, errorCode);
          },
        ),
        BuildButton(
          iconImage: const Image(
            height: 20,
            width: 20,
            image: AssetImage('assets/google.png'),
          ),
          textButton: 'Google',
          onPressed: () {
            // Add your Google login logic here
            // If error occurs:
            // _handleSocialLoginError(context, errorCode);
          },
        ),
      ],
    );
  }
}

class BuildButton extends StatelessWidget {
  final Image iconImage;
  final String textButton;
  final VoidCallback? onPressed;

  const BuildButton({
    super.key,
    required this.iconImage,
    required this.textButton,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: mediaQuery.height * 0.06,
        width: mediaQuery.width * 0.36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: (Colors.grey[300])!),
        ),
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
      ),
    );
  }
}