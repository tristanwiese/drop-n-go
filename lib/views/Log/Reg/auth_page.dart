import 'package:drop_n_go/views/Log/Reg/register_page.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  @override
  Widget build(BuildContext context) => isLogin
      ? LoginWidget(onClickSingUp: toggle)
      : RegisterWidget(onClickSingIn: toggle);

  void toggle() => setState(() => isLogin = !isLogin);
}
