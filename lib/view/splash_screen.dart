import 'package:flutter/material.dart';
import 'role_select.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3),);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn),);
    _controller.forward();
    gotoRoleSelectPage();
  }
  void gotoRoleSelectPage() async {
    await Future.delayed(const Duration(seconds: 3));
    selectRoleView();
  }
  void selectRoleView(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectRoleView()));
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              "assets/splash_view.png",
              width: media.width,
              height: media.height,
              fit: BoxFit.cover,
          ),
          ),
        ],
      ),
    );
  }
}