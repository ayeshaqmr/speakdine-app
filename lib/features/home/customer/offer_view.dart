import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class OfferView extends StatefulWidget {
  const OfferView({super.key});

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  List<Map> offerArr = [
    {
      "name": "KFC",
      "offer": "50% OFF",
      "desc": "Midnight Deals",
      "color": const Color(0xFFD32F2F) // Red
    },
    {
      "name": "Butt Karahi",
      "offer": "Free Naan",
      "desc": "On ordering Full Karahi",
      "color": const Color(0xFF388E3C) // Green
    },
    {
      "name": "Cheezious",
      "offer": "Buy 1 Get 1",
      "desc": "Large Pizza Special",
      "color": const Color(0xFFFBC02D) // Yellow/Gold
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
         padding: const EdgeInsets.only(bottom: 100),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const SizedBox(height: 60),
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 24),
               child: Text(
                 "Exclusive\nDeals",
                 style: TextStyle(
                   color: colorExt.primaryText,
                   fontSize: 42,
                   fontWeight: FontWeight.w900,
                   height: 1.0,
                   fontFamily: 'Metropolis'
                 ),
               ).animate().fadeIn().slideY(begin: -0.2),
             ),
             const SizedBox(height: 32),
             
             ListView.separated(
               physics: const NeverScrollableScrollPhysics(),
               shrinkWrap: true,
               padding: const EdgeInsets.symmetric(horizontal: 24),
               itemCount: offerArr.length,
               separatorBuilder: (_, __) => const SizedBox(height: 20),
               itemBuilder: (context, index) {
                 var mObj = offerArr[index];
                 return ClipPath(
                   clipper: const TicketClipper(),
                   child: Container(
                     height: 180,
                     decoration: BoxDecoration(
                       color: mObj["color"],
                     ),
                     child: Stack(
                       children: [
                         // Decorative Circles
                         Positioned(
                           right: -40,
                           top: -40,
                           child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withValues(alpha: 0.1)),
                         ),
                         Positioned(
                           left: -30,
                           bottom: -30,
                           child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withValues(alpha: 0.1)),
                         ),
                         
                         Padding(
                           padding: const EdgeInsets.all(24),
                           child: Row(
                             children: [
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                       decoration: BoxDecoration(
                                         color: Colors.white,
                                         borderRadius: BorderRadius.circular(8)
                                       ),
                                       child: Text(
                                         mObj["name"],
                                         style: TextStyle(color: mObj["color"], fontWeight: FontWeight.bold),
                                       ),
                                     ),
                                     const SizedBox(height: 12),
                                     Text(
                                       mObj["offer"],
                                       style: const TextStyle(
                                         color: Colors.white,
                                         fontSize: 32,
                                         fontWeight: FontWeight.w900,
                                       ),
                                     ),
                                     Text(
                                       mObj["desc"],
                                       style: const TextStyle(
                                         color: Colors.white,
                                         fontSize: 14,
                                         fontWeight: FontWeight.w500,
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                               const VerticalDivider(color: Colors.white54, width: 40, thickness: 1, indent: 20, endIndent: 20),
                               Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 50),
                                   const SizedBox(height: 8),
                                   Text(
                                     "SCAN",
                                     style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                                   )
                                 ],
                               )
                             ],
                           ),
                         ),
                       ],
                     ),
                   ).animate(delay: (index * 150).ms).slideX(begin: 0.2, curve: Curves.easeOutBack),
                 );
               },
             )
           ],
         ),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  const TicketClipper();

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    final radius = 10.0;
    
    // Left cutouts
    path.addOval(Rect.fromCircle(center: Offset(0, size.height / 2), radius: radius));
    
    // Right cutouts
    path.addOval(Rect.fromCircle(center: Offset(size.width, size.height / 2), radius: radius));

    return path..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
