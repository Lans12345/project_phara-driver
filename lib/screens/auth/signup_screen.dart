import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/signup.dart';
import '../../utils/colors.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/text_widget.dart';
import '../../widgets/textfield_widget.dart';
import '../../widgets/toast_widget.dart';
import '../splashtohome_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final addressController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey,
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/back.png'),
                fit: BoxFit.cover)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                TextBold(text: 'PHara', fontSize: 58, color: Colors.white),
                const SizedBox(
                  height: 25,
                ),
                TextRegular(text: 'Signup', fontSize: 24, color: Colors.white),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(label: 'Name', controller: nameController),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                    inputType: TextInputType.number,
                    label: 'Mobile Number',
                    controller: numberController),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                    inputType: TextInputType.streetAddress,
                    label: 'Address',
                    controller: addressController),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                    textCapitalization: TextCapitalization.none,
                    inputType: TextInputType.streetAddress,
                    label: 'Username',
                    controller: emailController),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                    textCapitalization: TextCapitalization.none,
                    showEye: true,
                    isObscure: true,
                    inputType: TextInputType.streetAddress,
                    label: 'Password',
                    controller: passwordController),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                    textCapitalization: TextCapitalization.none,
                    showEye: true,
                    isObscure: true,
                    inputType: TextInputType.streetAddress,
                    label: 'Confirm Password',
                    controller: confirmPasswordController),
                const SizedBox(
                  height: 25,
                ),
                Center(
                  child: ButtonWidget(
                    color: black,
                    label: 'Signup',
                    onPressed: (() {
                      register(context);
                    }),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextRegular(
                        text: "Already have an Account?",
                        fontSize: 12,
                        color: Colors.white),
                    TextButton(
                      onPressed: (() {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => LoginScreen()));
                      }),
                      child: TextBold(
                          text: "Login Now", fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  register(context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: '${emailController.text}@driver.phara',
          password: passwordController.text);

      signup(nameController.text, numberController.text, addressController.text,
          emailController.text);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: '${emailController.text}@driver.phara',
          password: passwordController.text);
      showToast("Registered Succesfully!");
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashToHomeScreen()));
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }
}
