import 'package:flutter/material.dart';
import '../../stats/screens/stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Just return the Stats Screen for now as our Dashboard
    return const StatsScreen();
  }
}