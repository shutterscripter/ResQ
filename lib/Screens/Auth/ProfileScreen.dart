import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resq/Screens/HomeScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _adharController = TextEditingController();
  final TextEditingController _drivingLicenseController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Create a reference to the 'drivers' collection
      CollectionReference drivers = FirebaseFirestore.instance.collection('drivers');

      // Get the document with the user's ID
      DocumentSnapshot docSnapshot = await drivers.doc(user.uid).get();

      // If the document exists, update the TextEditingControllers with the data
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _ageController.text = data['age'] ?? '';
        _cityController.text = data['city'] ?? '';
        _adharController.text = data['adhar'] ?? '';
        _drivingLicenseController.text = data['drivingLicense'] ?? '';
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text('Email'),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text('Age'),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    hintText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLength: 2,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text('City'),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'City',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text('Adhar Number'),
                TextFormField(
                  controller: _adharController,
                  maxLength: 12,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Adhar Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter adhar number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text('Driving License Number'),
                TextFormField(
                  controller: _drivingLicenseController,
                  maxLength: 16,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Driving License Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter driving license number';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white),
                  onPressed: () async {
                    var name = _nameController.text;
                    var email = _emailController.text;
                    var age = _ageController.text;
                    var city = _cityController.text;
                    var adhar = _adharController.text;
                    var drivingLicense = _drivingLicenseController.text;

                    await storeDataIntoFirebase(
                        name, email, age, city, adhar, drivingLicense);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  storeDataIntoFirebase(String name, String email, String age, String city,
      String adhar, String drivingLicense) async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Create a reference to the 'drivers' collection
      CollectionReference drivers =
          FirebaseFirestore.instance.collection('drivers');

      // Prepare the user data
      Map<String, dynamic> userData = {
        'name': name, // Add the user's name
        'email': email, // Add the user's email
        'age': age, // Add the user's age
        'city': city, // Add the user's city
        'adhar': adhar, // Add the user's adhar
        'drivingLicense': drivingLicense, // Add the user's driving license
      };

      // Create a new document with the user's ID and set the user data
      DocumentReference docRef = drivers.doc(user.uid);

      await docRef.set(userData).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Updated Successfully!')));
        Get.to(const HomeScreen());
      }).catchError((error) => print("Failed to add user data: $error"));
    } else {
      print("No user is signed in.");
    }
  }
}
