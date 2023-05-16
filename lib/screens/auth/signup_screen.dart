import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phara_driver/screens/terms_conditions_page.dart';

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
  final vehicleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey,
      body: Form(
        key: _formKey,
        child: Container(
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
                  TextBold(text: 'PARA', fontSize: 58, color: Colors.white),
                  const SizedBox(
                    height: 25,
                  ),
                  TextRegular(
                      text: 'Signup', fontSize: 24, color: Colors.white),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    label: 'Name',
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    inputType: TextInputType.number,
                    label: 'Mobile Number',
                    controller: numberController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a mobile number';
                      } else if (value.length != 11 ||
                          !value.startsWith('09')) {
                        return 'Please enter a valid mobile number';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    inputType: TextInputType.streetAddress,
                    label: 'Address',
                    controller: addressController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    inputType: TextInputType.streetAddress,
                    label: 'Vehicle Model',
                    controller: vehicleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a vehicle model';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    textCapitalization: TextCapitalization.none,
                    inputType: TextInputType.streetAddress,
                    label: 'Username',
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    textCapitalization: TextCapitalization.none,
                    showEye: true,
                    isObscure: true,
                    inputType: TextInputType.streetAddress,
                    label: 'Password',
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      final hasUppercase = value.contains(RegExp(r'[A-Z]'));
                      final hasLowercase = value.contains(RegExp(r'[a-z]'));
                      final hasNumber = value.contains(RegExp(r'[0-9]'));
                      if (!hasUppercase || !hasLowercase || !hasNumber) {
                        return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    textCapitalization: TextCapitalization.none,
                    showEye: true,
                    isObscure: true,
                    inputType: TextInputType.streetAddress,
                    label: 'Confirm Password',
                    controller: confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value != passwordController.text) {
                        return 'Password do not match';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Center(
                    child: ButtonWidget(
                      color: black,
                      label: 'Signup',
                      onPressed: (() {
                        if (_formKey.currentState!.validate()) {
                          register(context);
                        }
                      }),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: TextRegular(
                        text: 'Signing up means you agree to our',
                        fontSize: 12,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const TermsAndConditionsPage()));
                      },
                      child: TextBold(
                          text: 'Terms and Conditions',
                          fontSize: 14,
                          color: Colors.white),
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
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        }),
                        child: TextBold(
                            text: "Login Now",
                            fontSize: 14,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
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
          emailController.text, vehicleController.text);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: '${emailController.text}@driver.phara',
          password: passwordController.text);
      showToast("Registered Succesfully!");
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashToHomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that username.');
      } else if (e.code == 'invalid-email') {
        showToast('The username is not valid.');
      } else {
        showToast(e.toString());
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }
}
