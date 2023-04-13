// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import '../../../services/utils.dart';

class RegisterWidget extends StatefulWidget {
  final VoidCallback onClickSingIn;

  const RegisterWidget({
    Key? key,
    required this.onClickSingIn,
  }) : super(key: key);

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String errorMessage;

  bool _passwordVisible = true;
  bool _confirmPasswordVisible = true;

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
          child: Logo(),
        ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            SizedBox(
              width: 250,
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
              width: 250,
              child: TextFormField(
                controller: passwordController,
                obscureText: _passwordVisible,
                decoration: InputDecoration(
                  hintText: 'Password',
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minHeight: 24,
                    minWidth: 24,
                  ),
                  suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                  // else if (errorMessage.contains('password')) {
                  //   return errorMessage;
                  // }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 250,
              child: TextFormField(
                obscureText: _confirmPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minHeight: 24,
                    minWidth: 24,
                  ),
                  suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      }),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password required';
                  } else if (value != passwordController.text) {
                    return "Password does not match";
                  }
                  return null;
                },
              ),
            ),
            const  SizedBox(height: 10),
            SizedBox(
              height: 40,
              width: 150,
              child: ElevatedButton(
                onHover: (value) => setState(() {
                  Utils.loginButtonHover(value);
                }),
                style: ElevatedButton.styleFrom(backgroundColor: Utils.loginButtonColor),
                  onPressed: () {
                    signUp();
                  },
                  child: const Text('Create User', style: TextStyle(fontSize: 20),)),
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
                  onPressed: widget.onClickSingIn,
                  child: const Text('Login', style: TextStyle(fontSize: 20),)),
            ),
          ]),
        ),
      ),
    );
  }

  Future signUp() async {
    if(!_formKey.currentState!.validate()){
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    print('fired');
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
       Utils.showSnackBar(e.message);
       Navigator.of(context).popUntil((route) => route.isFirst);
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
