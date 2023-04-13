import 'package:flutter/material.dart';

class Utils {

 // static dynamic user = FirebaseFirestore.instance.collection('users').doc(uid);
  
  static Color? loginButtonColor = Colors.green;
  static Color? registerButtonColor = Colors.green;

  static loginButtonHover(value) {
    value
        ? loginButtonColor = Colors.green[200]
        : loginButtonColor = Colors.green;
  }

  static registerButtonHover(value) {
    value
        ? registerButtonColor = Colors.green[200]
        : registerButtonColor = Colors.green;
  }

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static showSnackBar(String? text) {
    if (text == null) {
      return;
    }

    final snackBar = SnackBar(content: Text(text), backgroundColor: Colors.red);

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

class Logo extends StatelessWidget {
  const Logo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
          children: const [
    Text('Drop n Go', style: TextStyle(fontSize: 100)),
    Icon(Icons.location_on_outlined, size: 60, color: Colors.green,),
          ],
        );
  }
}
