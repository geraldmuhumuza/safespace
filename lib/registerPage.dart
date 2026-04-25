// ignore_for_file: unused_element, use_build_context_synchronously, unused_field, unused_import
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:safehome/main.dart';
import 'package:show_hide_password/show_hide_password_text_field.dart';

import 'api/auth_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _contact = TextEditingController();
  final _passwordconfirm = TextEditingController();
  final _lastName = TextEditingController();
  final _firstname = TextEditingController();
  final _dOBController = TextEditingController();

  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dOBController.text = "${picked.toLocal()}".split(
          ' ',
        )[0]; // Format as YYYY-MM-DD
      });
    }
  }

  Future<bool> userExists({
    required String email,
    required String contact,
  }) async {
    final emailQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (emailQuery.docs.isNotEmpty) {
      return true;
    }

    final phoneQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('Contact', isEqualTo: contact)
        .limit(1)
        .get();

    return phoneQuery.docs.isNotEmpty;
  }

  // Future<void> saveUser(BuildContext context) async {
  //   final email = _email.text.trim();
  //   final contact = _contact.text.trim();
  //   final lastname = _lastName.text.trim();
  //   final firstname = _firstname.text.trim();
  //   final password = _password.text.trim();
  //   final passwordConfirm = _passwordconfirm.text.trim();
  //   final dob = _dOBController.text.trim();

  //   if (email.isEmpty ||
  //       contact.isEmpty ||
  //       firstname.isEmpty ||
  //       lastname.isEmpty ||
  //       password.isEmpty ||
  //       passwordConfirm.isEmpty ||
  //       dob.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("All fields are required")));
  //     return;
  //   }

  //   if (password != passwordConfirm) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
  //     return;
  //   }

  //   // ✅ Check duplicates
  //   final exists = await userExists(email: email, contact: contact);
  //   if (!mounted) return;
  //   if (exists) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Email or phone already exists"),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }

  //   try {
  //     // Create Auth account
  //     UserCredential userCredential = await FirebaseAuth.instance
  //         .createUserWithEmailAndPassword(email: email, password: password);

  //     final uid = userCredential.user!.uid;
  //     debugPrint(uid);

  //     // Save profile
  //     await FirebaseFirestore.instance.collection('users').doc(uid).set({
  //       'email': email,
  //       'Contact': contact,
  //       'firstname': firstname,
  //       'lastname': lastname,
  //       'DOB': dob,
  //       'createdAt': FieldValue.serverTimestamp(),
  //     });

  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Registered successfully")));

  //     Provider.of<UserProvider>(context, listen: false).setUser(
  //       AppUser(
  //         uid: uid,
  //         email: email,
  //         firstName: firstname,
  //         lastName: lastname,
  //         contact: contact,
  //         createdAt: FieldValue.serverTimestamp().toString(),
  //       ),
  //     );

  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => SafeSpace()),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(e.message ?? "Registration failed")),
  //     );
  //   }
  // }

  Future<void> _handleRegister({bool fromCamera = false}) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final email = _email.text.trim();
    final contact = _contact.text.trim();
    final lastname = _lastName.text.trim();
    final firstname = _firstname.text.trim();
    final password = _password.text.trim();
    final passwordConfirm = _passwordconfirm.text.trim();
    final dob = _dOBController.text.trim();

    if (email.isEmpty ||
        contact.isEmpty ||
        firstname.isEmpty ||
        lastname.isEmpty ||
        password.isEmpty ||
        passwordConfirm.isEmpty ||
        dob.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    if (password != passwordConfirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    // ✅ Check duplicates
    final exists = await userExists(email: email, contact: contact);
    if (!mounted) return;
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email or phone already exists"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await authService.signUp(
      firstname: firstname,
      lastname: lastname,
      email: email,
      contact: contact,
      dob: dob,
      password: password,
    );

    if (!success && mounted) {
      debugPrint("Registration failed: ${authService.errorMessage}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.errorMessage ?? ' Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
    _contact.dispose();
    _dOBController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        // backgroundColor: Colors.blue,
      ),
      body: Container(
        alignment: Alignment.bottomCenter,
        //color: const Color.fromARGB(255, 185, 217, 232),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "WELCOME TO SAFESPACE",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                  //backgroundColor: Colors.purple
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FractionallySizedBox(
                  widthFactor: 1.0,
                  child: TextFormField(
                    controller: _firstname,
                    decoration: const InputDecoration(
                      labelText: "Enter First Name",
                      border: OutlineInputBorder(),
                      hintText: 'Enter First Name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FractionallySizedBox(
                  widthFactor: 1.0,
                  child: TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(
                      labelText: 'Enter Last Name',
                      border: OutlineInputBorder(),
                      hintText: 'Enter Last Name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: TextFormField(
                    controller: _email,
                    style: const TextStyle(
                      fontSize: 20.0,
                      height: 2.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      hintText: "Email",
                      //labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black38, width: 1),
                        //borderRadius: BorderRadius.circular(5),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSaved: (String? value) {
                      if (value!.isEmpty) {
                        return;
                      } else {
                        if (value.contains('@')) {
                          if (value.endsWith(".com")) {
                          } else {
                            return;
                          }
                        } else {
                          return;
                        }
                      }
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      } else {
                        if (value.contains('@')) {
                          if (value.endsWith(".com")) {
                            return null;
                          } else {
                            return 'Please enter a valid email';
                          }
                        } else {
                          return 'Please enter a valid email';
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FractionallySizedBox(
                  widthFactor: 1.0,
                  child: TextFormField(
                    controller: _dOBController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'D.O.B',
                      fillColor: Colors.black,
                      labelText: 'Date Of Birth',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDOB(context),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: TextFormField(
                    controller: _contact,
                    style: const TextStyle(
                      fontSize: 20.0,
                      height: 2.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      hintText: "Contact",
                      //labelText: 'Email',
                      prefixIcon: Icon(Icons.contact_phone),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black38, width: 1),
                        //borderRadius: BorderRadius.circular(5),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSaved: (String? value) {},
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your contact';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ShowHidePasswordTextField(
                    controller: _password,
                    fontStyle: const TextStyle(
                      fontSize: 20,
                      height: 2.0,
                      fontWeight: FontWeight.normal,
                    ),
                    textColor: const Color(0xff010101),
                    hintColor: const Color(0xff060606),
                    iconSize: 20,
                    //visibleOffIcon: Iconsax.eye_slash,
                    //visibleOnIcon: Iconsax.eye,
                    decoration: InputDecoration(
                      isDense: true,
                      //hintText: 'Enter Password',
                      labelText: 'Enter Password',
                      hintStyle: Theme.of(context).textTheme.labelMedium!
                          .copyWith(
                            color: Colors.black38,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black38,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black38,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ShowHidePasswordTextField(
                    controller: _passwordconfirm,
                    fontStyle: const TextStyle(
                      fontSize: 20,
                      height: 2.0,
                      fontWeight: FontWeight.normal,
                    ),
                    textColor: const Color(0xff010101),
                    hintColor: const Color(0xff060606),
                    iconSize: 20,
                    //visibleOffIcon: Iconsax.eye_slash,
                    //visibleOnIcon: Iconsax.eye,
                    decoration: InputDecoration(
                      isDense: true,
                      //hintText: 'Confirm Password',
                      labelText: 'Confirm Password',
                      hintStyle: Theme.of(context).textTheme.labelMedium!
                          .copyWith(
                            color: Colors.black38,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black38,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black38,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleRegister,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      fixedSize: const Size.fromWidth(40),
                      textStyle: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: const Color(0xffd00c96),
                      foregroundColor: Colors.white,
                      elevation: 25,
                      shadowColor: const Color(0xe1413f3f),
                    ),
                    child: const Text(
                      "REGISTER",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
