import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final PageController _pageController = PageController();
  final List<String> _videoPaths = [
    'assets/videos/pearl.mp4',
    'assets/videos/sonhe.mp4',
    'assets/videos/dive.mp4',
  ];

  final List<VideoPlayerController> _videoControllers = [];
  final List<ChewieController> _chewieControllers = [];

  // Sesijos ir vartotojo servisai
  final AuthService _authService = AuthService();
  bool isDarkMode = false; // Temos būsena

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Gauname sesijos duomenis

    for (var path in _videoPaths) {
      final videoController = VideoPlayerController.asset(path);
      videoController.initialize().then((_) {
        final chewieController = ChewieController(
          videoPlayerController: videoController,
          autoPlay: false,
          looping: true,
        );

        setState(() {
          _videoControllers.add(videoController);
          _chewieControllers.add(chewieController);
        });
      });
    }
  }

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchUserData() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      setState(() {
        isDarkMode =
            sessionData['darkMode'] == 'true'; // Gauname darkMode iš sesijos
      });
    } catch (e) {
      if (mounted) {
        String message = 'Klaida gaunant duomenis ❌';
        showCustomSnackBar(context, message, false);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _videoControllers) {
      c.dispose();
    }
    for (final c in _chewieControllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double topPadding = 25.0;
    const double horizontalPadding = 20.0;
    const double bottomPadding = 20.0;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: topPadding),
              Expanded(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: horizontalPadding),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[800]! : Colors.white,
                      width: 20,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 30,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Meditacija',
                        style: TextStyle(
                          fontSize: 30,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _chewieControllers.length,
                          itemBuilder: (context, index) {
                            if (_chewieControllers.length > index &&
                                _videoControllers[index].value.isInitialized) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Chewie(
                                    controller: _chewieControllers[index]),
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.deepPurple,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _videoPaths.length,
                        effect: WormEffect(
                          dotColor:
                              isDarkMode ? Colors.grey[700]! : Colors.grey,
                          activeDotColor:
                              isDarkMode ? Colors.white : Colors.deepPurple,
                          dotHeight: 10,
                          dotWidth: 10,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              const BottomNavigation(),
              SizedBox(height: bottomPadding),
            ],
          ),
        ],
      ),
    );
  }
}
