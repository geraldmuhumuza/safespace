import 'package:flutter/material.dart';
import 'package:show_hide_password/show_hide_password_text_field.dart';

import 'landingFunctions/loginUser.dart';

class PassworPage extends StatefulWidget {
  const PassworPage({super.key, required this.email});
  final String email;

  @override
  State<PassworPage> createState() => _PassworPageState();
}

class _PassworPageState extends State<PassworPage> {
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Password")),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ShowHidePasswordTextField(
                  controller: _passwordController,
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
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  final String password = _passwordController.text.trim();
                  loginUser(context, mounted, widget.email, password);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(10),
                  fixedSize: const Size.fromWidth(40),
                  textStyle: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.white,
                  elevation: 25,
                  shadowColor: const Color(0xe1413f3f),
                ),
                child: Text('LOGIN'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
