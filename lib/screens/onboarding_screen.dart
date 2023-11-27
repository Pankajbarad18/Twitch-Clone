import 'package:flutter/material.dart';
import 'package:twitch_clone/responsive/responsive.dart';
import 'package:twitch_clone/screens/login_screen.dart';
import 'package:twitch_clone/screens/signup_screen.dart';
import 'package:twitch_clone/utilities/colors.dart';
import 'package:twitch_clone/widgets/custom_buttons.dart';

class Onboarding extends StatelessWidget {
  static String routeName = '/onboarding';
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome\nTo Twitch',
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: buttonColor),
              ),
              const SizedBox(
                height: 40,
              ),
              CustomButton(
                  onTap: () =>
                      Navigator.pushNamed(context, LoginScreen.routeName),
                  text: 'Log in'),
              const SizedBox(
                height: 20,
              ),
              CustomButton(
                onTap: () =>
                    Navigator.pushNamed(context, SignUpScreen.routeName),
                text: 'Sign Up',
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
