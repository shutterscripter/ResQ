import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resq/Controller/AuthControllers/OtpVerifiController.dart';
import 'package:resq/Screens/Auth/ProfileScreen.dart';

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
      body: Container(
        margin: const EdgeInsets.only(top: 50, right: 20, left: 20),
        child: Column(
          children: [
            const Text(
              "Menu",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Profile'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Get.to(const ProfileScreen());
              },
            ),
            // const Divider(
            //   height: 1,
            //   color: Colors.grey,
            // ),
            // ListTile(
            //   title: const Text('Settings'),
            //   trailing: const Icon(Icons.arrow_forward_ios_rounded),
            //   onTap: () {},
            // ),
            const Divider(
              height: 1,
              color: Colors.grey,
            ),
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              AuthService.logout();
                              Get.offAll(const SignInScreen());
                            },
                            child: const Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('No'),
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}
