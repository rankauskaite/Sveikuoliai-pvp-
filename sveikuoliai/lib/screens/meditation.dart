import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final PageController _pageController = PageController();
  final List<String> _videoPaths = [
    //'assets/videos/meditation.mp4',
    'assets/videos/pearl.mp4',
    'assets/videos/sonhe.mp4',
    'assets/videos/dive.mp4',
  ];

  final List<VideoPlayerController> _videoControllers = [];
  final List<ChewieController> _chewieControllers = [];

  @override
  void initState() {
    super.initState();

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
    return Scaffold(
      backgroundColor: const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 20,
        backgroundColor: const Color(0xFF8093F1),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              width: 320,
              height: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, size: 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Meditacija', style: TextStyle(fontSize: 30)),
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
                            child:
                                Chewie(controller: _chewieControllers[index]),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _videoPaths.length,
                    effect: const WormEffect(
                      dotColor: Colors.grey,
                      activeDotColor: Colors.deepPurple,
                      dotHeight: 10,
                      dotWidth: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const BottomNavigation(),
          ],
        ),
      ),
    );
  }
}
