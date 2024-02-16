import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMainController extends GetxController {
  var phoneNum = '';

  ///this method is used to send otp to using firebase
  Future registerUser(String mobile, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: Duration(seconds: 60),
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
        codeSent: (String verificationId, [int? forceResendingToken]) {
          Get.snackbar('Success', 'OTP sent');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          Get.snackbar('Error', 'Time out');
        });
  }
}
