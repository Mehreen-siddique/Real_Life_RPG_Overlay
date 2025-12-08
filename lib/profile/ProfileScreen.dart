
import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/users.dart';

class profileScreen extends StatefulWidget {
  const profileScreen({super.key});

  @override
  State<profileScreen> createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = UserModel.dummy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
