import 'package:flutter/material.dart';
import 'package:sveikuoliai/screens/profile.dart';
import 'package:sveikuoliai/services/auth_services.dart';

class ProfileButton extends StatefulWidget {
  const ProfileButton({super.key});

  @override
  _ProfileButtonState createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  final AuthService _authService = AuthService();
  String? _iconPath;

  @override
  void initState() {
    super.initState();
    _fetchSessionIcon();
  }

  Future<void> _fetchSessionIcon() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      setState(() {
        _iconPath = sessionData['icon'];
      });
    } catch (e) {
      // Handle error silently, default to account_circle
      setState(() {
        _iconPath = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: _iconPath == null || _iconPath!.isEmpty
              ? const Icon(Icons.account_circle, size: 60)
              : Image.asset(
                  _iconPath!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
          color: const Color(0xFFD9D9D9),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
      ],
    );
  }
}
