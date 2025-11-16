import 'package:flutter/material.dart';
import 'package:real_life_rpg/utils/constants.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {



  //header of the screen...
  Widget buildHeader(){
    return Row(
      children: [
        //Avatar
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [
              AppColors.primaryPurple,
              AppColors.electricBlue
            ]),
            border: Border.all(
              color: AppColors.goldYellow,
              width: 3
            )
          ),
      child:  Icon(
        Icons.person,
        color: Colors.white,
        size: 32,
      ),
    ),
        SizedBox(width: 12,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assalam Alaikum! 👋',
              style: AppTextStyles.body,
            ),



          ],
        )

      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
          child:
      SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            SizedBox(height: 20)
          ],
        ),
      )

      ),
    );
  }
}
