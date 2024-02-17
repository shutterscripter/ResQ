import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:resq/Controller/AuthControllers/AuthMainController.dart';
import 'package:resq/Controller/AuthControllers/OtpVerifiController.dart';
import 'package:resq/Screens/Auth/OtpVerifyScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthMainController _authMainController = Get.put(AuthMainController());
  var id = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 60,
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/auth_picture.png'),
                const SizedBox(height: 20),
                const Text(
                  "Hello, Welcome",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Welcome to ResQ. Please sign in to continue.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                IntlPhoneField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      borderSide: BorderSide(),
                    ),
                  ),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {
                    _authMainController.phoneNum = phone.completeNumber;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    AuthService.sentOtp(
                      phone: _authMainController.phoneNum,
                      errorStep: () {
                        Get.snackbar(
                          "Error",
                          "Error in sending OTP",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      nextStep: () {
                        setState(() {
                          id = AuthService.verifyId;
                        });
                        Get.to(() => MyVerify(
                              id: id,
                            ));
                      },
                    );
                  },
                  child: const Text("SignIn/SignUp"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
