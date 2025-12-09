
import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/utils/constants.dart';



class QuestDetailScreen extends StatefulWidget {
  final Quest quest;
  const QuestDetailScreen({Key? key, required this.quest}) : super(key: key);

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends State<QuestDetailScreen> {
  // initialization:

  late Quest _quest;
  bool _isTimerRunning = false;
  int _elapsedSeconds = 0;


  @override
  void initState() {
    super.initState();
    _quest = widget.quest;
  }


  Widget _buildTag({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        backgroundColor: AppColors.lightBackground,
       body: CustomScrollView(
         slivers: [

           //AppBar
           SliverAppBar(
             expandedHeight: 200,
             pinned: true,
             backgroundColor: Colors.transparent,
             leading: IconButton(
               icon: const Icon(Icons.arrow_back, color: Colors.white),
               onPressed: () => Navigator.pop(context),
             ),
             actions: [
               Container(
                 decoration: BoxDecoration(
                   color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                 ),
                 child: IconButton(onPressed: (){},
                   icon: const Icon(
                       Icons.edit,
                       color: Colors.white,
                     size: 20,
                   ),


                 ),
               ),
               SizedBox(width: 10,),
               Container(
                 decoration: BoxDecoration(
                   color: Colors.white.withOpacity(0.1),
                   shape: BoxShape.circle,
                 ),
                 child: IconButton(
                   icon: const Icon(
                       Icons.delete,
                       color: Colors.white,
                     size: 20,
                   ),
                   onPressed:(){},
                   //_deleteQuest,
                 ),
               ),
               SizedBox(width: 10,),
             ],
             flexibleSpace: FlexibleSpaceBar(
               background: Container(
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     colors: _quest.gradientColors,
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                   ),
                   borderRadius: BorderRadius.only(
                     bottomRight: Radius.circular(40),
                     bottomLeft: Radius.circular(40),
                   ),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black38.withOpacity(0.1),
                       spreadRadius: 5,
                       blurRadius: 15,
                       offset: Offset(0, 4),
                     ),
                   ],

                 ),
                 child: Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       SizedBox(height: 40),
                       Container(
                         width: 100,
                         height: 100,
                         decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                           shape: BoxShape.circle,
                         ),
                         child: Icon(
                           _quest.icon, size: 60,
                           color: Colors.white,
                         ),
                       )
                     ],
                   ),
                 ),
               ),
             ),

           ),
           SliverToBoxAdapter(

           )
         ],

       ),


      );
  }


}
