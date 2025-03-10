import 'package:flutter/material.dart';
import 'package:sveikuoliai/main.dart';
import 'package:sveikuoliai/screens/journal.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavItem(
          context,
          icon: Icons.library_books_outlined,
          destination: const JournalScreen(),
        ),
        _buildNavItem(
          context,
          icon: Icons.home_outlined,
          destination: const MainScreen(),
        ),
        _buildNavItem(
          context,
          icon: Icons.check_circle_outline,
          destination: const HabitsGoalsScreen(),
        ),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context,
      {required IconData icon, required Widget destination}) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: IconButton(
              icon: Icon(icon, size: 35),
              color: const Color(0xFF8093F1),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => destination),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
