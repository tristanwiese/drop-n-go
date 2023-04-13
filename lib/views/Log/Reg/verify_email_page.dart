import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drop_n_go/views/initializer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../services/utils.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState(){
    super.initState();

    checkIfDocExists(FirebaseAuth.instance.currentUser!.uid);

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    
    if (!isEmailVerified){
      sendVerificationEmail();

      timer = Timer.periodic(const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose(){
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async{
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified){
      timer?.cancel();
    }
  }
  Future<void> sendVerificationEmail() async{
    try{
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification();
    }
    catch (e){
      Utils.showSnackBar(e.toString());
    }
  }


  @override
  Widget build(BuildContext context) => isEmailVerified
    ? const Initializer()
    : Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Verification Email has been sent, Click on link and you will be redirected to the Home Page'),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: (){
                FirebaseAuth.instance.signOut();
              }, 
              child: const Text('Cancel')),
              const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    sendVerificationEmail();
                  },
                  icon: const Icon(Icons.email_outlined),
                  label: const Text(
                    'Resend Email',
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  

  checkIfDocExists(String docId) async{
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('users');


      var doc = await collectionRef.doc(docId).get();
      if (doc.exists){
        return;
      }
      else{
        final user = {'id':docId};   
        FirebaseFirestore.instance.collection('users').doc(docId).set(user);
      }
    } catch (e) {
      rethrow;
    }
  }
}