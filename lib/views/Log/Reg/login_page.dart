// ignore_for_file: use_build_context_synchronously
import 'package:drop_n_go/services/nav.dart';
import 'package:drop_n_go/views/Log/Reg/reset_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../services/utils.dart';

class LoginWidget extends StatefulWidget {
  final VoidCallback onClickSingUp;

  const LoginWidget({
    Key? key,
    required this.onClickSingUp,
  }) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _passwordVisible = true;

  dynamic emailController = TextEditingController();
  dynamic passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
            child: Form(
      key: _formKey,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(
            child: Logo()),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        SizedBox(
          width: 200,
          child: TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              hintText: 'Email',
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email required';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 200,
          child: TextFormField(
            controller: passwordController,
            obscureText: _passwordVisible,
            decoration: InputDecoration(
              hintText: 'Password',
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              suffixIconConstraints: const BoxConstraints(
                minHeight: 24,
                minWidth: 24,
              ),
              suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  }),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password required';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          width: 150,
          child: ElevatedButton(
              onHover: (value) => setState(() {
                Utils.loginButtonHover(value);
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Utils.loginButtonColor,
              ),
              onPressed: () {
                signIn();
              },
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 20),
              )),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          width: 150,
          child: ElevatedButton(
              onHover: (value) => setState(() {
                Utils.registerButtonHover(value);
              }),
              style: ElevatedButton.styleFrom(backgroundColor: Utils.registerButtonColor),
              onPressed: widget.onClickSingUp,
              child: const Text(
                'Register',
                style: TextStyle(fontSize: 20),
              )),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(children: <TextSpan>[
            TextSpan(
                text: 'Forgot Password',
                style: const TextStyle(
                    decoration: TextDecoration.underline, color: Colors.teal),
                recognizer: TapGestureRecognizer()
                  ..onTap =
                      () => navPush(context, const ResetPasswordWidget())),
          ]),
        ),
        const SizedBox(height: 5),
      ]),
    )));
  }

  Future signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    }
    navPop(context);
  }
}


