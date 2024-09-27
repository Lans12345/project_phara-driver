import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../plugins/my_location.dart';
import '../../utils/colors.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/text_widget.dart';
import 'login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            color: grey,
            image: DecorationImage(
                opacity: 150,
                image: AssetImage('assets/images/newimg.jfif'),
                fit: BoxFit.cover)),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextBold(text: 'PASADA', fontSize: 48, color: Colors.white),
                TextRegular(
                    text: 'Making your travels more easier',
                    fontSize: 15,
                    color: Colors.white),
                const SizedBox(
                  height: 75,
                ),
                Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      ButtonWidget(
                        label: 'Login',
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ])),
                const SizedBox(
                  height: 200,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  googleLogin() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

      final googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        return;
      }
      final googleSignInAuth = await googleSignInAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuth.accessToken,
        idToken: googleSignInAuth.idToken,
      );

      // createAccountFirestore(
      //     googleSignInAccount.email,
      //     googleSignInAccount.photoUrl!,
      //     googleSignInAccount.displayName!);

      // signup(
      //     googleSignInAccount.displayName, '', '', googleSignInAccount.email);

      await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception {
      Fluttertoast.showToast(msg: 'Cannot Proceed!');
    }
  }
}
