import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resq/Screens/Auth/OtpVerifyScreen.dart';

class AuthMainController extends GetxController {
  var phoneNum = '';

  ///this method is used to send otp to using firebase
  Future registerUser(String mobile, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) {
          _auth
              .signInWithCredential(authCredential)
              .then((UserCredential result) {
            Get.snackbar('Success', 'User is verified');
          }).catchError((e) {
            Get.snackbar('Error', e.toString());
          });
        },
        verificationFailed: (FirebaseAuthException authException) {
          Get.snackbar('Error', authException.message.toString());
        },
        codeSent: (String verificationId, [int? forceResendingToken]) async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Please check your phone for the verification code'),
            ),
          );
          Future.delayed(const Duration(seconds: 4), () {

          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          Get.snackbar('Error', 'Time out');
        });
  }
}
