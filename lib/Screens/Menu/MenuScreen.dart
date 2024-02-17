import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resq/Controller/AuthControllers/OtpVerifiController.dart';

import '../Auth/AuthMainScreen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            AuthService.logout();
            Get.offAll(const SignInScreen());
          },
          child: Text('Menu Screen'),
        ),
      ),
    );
  }
}
