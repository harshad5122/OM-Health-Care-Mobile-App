import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeInAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Get.offAllNamed(AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF7F6),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD7F3EC), Color(0xFFEFF7F6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Center logo with fade animation
          FadeTransition(
            opacity: _fadeInAnimation,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icon/01.png',
                    width: 180,
                    height: 180,
                  ),
                  // const SizedBox(height: 20),
                  // const Text(
                  //   'OM Physio Care',
                  //   style: TextStyle(
                  //     fontSize: 26,
                  //     fontWeight: FontWeight.bold,
                  //     color: Color(0xFF00796B),
                  //     letterSpacing: 1.2,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          // Bottom tagline
          // Positioned(
          //   bottom: 30,
          //   left: 0,
          //   right: 0,
          //   child: FadeTransition(
          //     opacity: _fadeInAnimation,
          //     child: const Text(
          //       'Healing through movement ✨',
          //       textAlign: TextAlign.center,
          //       style: TextStyle(
          //         fontSize: 14,
          //         color: Colors.teal,
          //         fontStyle: FontStyle.italic,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
