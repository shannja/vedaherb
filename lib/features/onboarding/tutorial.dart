import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:vedaherb/core/theme.dart';
import 'package:vedaherb/main.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Tutorial content: titles, descriptions, and theme-specific assets.
  final List<Map<String, String>> _tutorialData = [
    {
      'title': 'It\'s offline, and powerful',
      'description': 'Use your camera and chat with an AI to address mild symptoms with herbal remedies, fully offline.',
      'imageLight': 'assets/images/illustrations/tutorial/tutorial_1-light.png',
      'imageDark': 'assets/images/illustrations/tutorial/tutorial_1-dark.png',
    },
    {
      'title': 'Built for ASEAN',
      'description': 'Tailored specifically for the biodiversity of Southeast Asia. Access local herbs and remedies for your mild symptoms.',
      'imageLight': 'assets/images/illustrations/tutorial/tutorial_2-light.png',
      'imageDark': 'assets/images/illustrations/tutorial/tutorial_2-dark.png',
    },
    {
      'title': 'Preserving tradition',
      'description': 'Bringing traditional wisdom into the modern world with safety and clarity from government health data and research.',
      'imageLight': 'assets/images/illustrations/tutorial/tutorial_3-light.png',
      'imageDark': 'assets/images/illustrations/tutorial/tutorial_3-dark.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? VedaTheme.darkBg : VedaTheme.lightBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _tutorialData.length,
                    itemBuilder: (context, index) {
                      final data = _tutorialData[index];
                      final imagePath = isDark ? data['imageDark'] : data['imageLight'];
                      final bool isVisible = _currentPage == index;

                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(imagePath ?? '', height: 250),
                            const SizedBox(height: 30),
                            
                            /// Entry animation for Title.
                            AnimatedSlide(
                              offset: isVisible ? Offset.zero : const Offset(0, 0.2),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              child: AnimatedOpacity(
                                opacity: isVisible ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 600),
                                child: Text(
                                  data['title']!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.displayLarge
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            
                            /// Entry animation for Description (staggered slightly slower).
                            AnimatedSlide(
                              offset: isVisible ? Offset.zero : const Offset(0, 0.4),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              child: AnimatedOpacity(
                                opacity: isVisible ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 800),
                                child: Text(
                                  data['description']!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _buildBottomSection(isDark),
              ],
            ),
            
            /// Floating Theme Toggle.
            Positioned(
              top: 10,
              right: 10,
              child: Consumer(
                builder: (context, ref, child) {
                  // 1. Watch the current theme mode
                  final themeMode = ref.watch(themeProvider);
                  
                  // 2. Define the icon based on the 3 states
                  IconData themeIcon;
                  switch (themeMode) {
                    case ThemeMode.light:
                      themeIcon = Icons.light_mode_rounded;
                      break;
                    case ThemeMode.dark:
                      themeIcon = Icons.dark_mode_rounded;
                      break;
                    case ThemeMode.system:
                    themeIcon = Icons.brightness_auto_rounded; // Represents "System"
                      break;
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: VedaTheme.brandGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        themeIcon,
                        color: VedaTheme.brandGreen,
                      ),
                      onPressed: () {
                        // 3. Cycle logic: System -> Light -> Dark -> (back to System)
                        ThemeMode nextMode;
                        if (themeMode == ThemeMode.system) {
                          nextMode = ThemeMode.light;
                        } else if (themeMode == ThemeMode.light) {
                          nextMode = ThemeMode.dark;
                        } else {
                          nextMode = ThemeMode.system;
                        }
                        
                        ref.read(themeProvider.notifier).state = nextMode;
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigation controls and page indicators.
  Widget _buildBottomSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// 'Back' button: Hidden on the first page.
          IgnorePointer(
            ignoring: _currentPage == 0,
            child: AnimatedOpacity(
              opacity: _currentPage == 0 ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: TextButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                  );
                },
                child: Text(
                  'Back',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: VedaTheme.brandGreen,
                  ),
                ),
              ),
            ),
          ),

          /// Animated dot indicators.
          Row(
            children: List.generate(
              _tutorialData.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentPage == index
                      ? VedaTheme.brandGreen
                      : VedaTheme.brandGreen.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

          /// 'Next' / 'Start' button: Saves onboarding state upon completion.
          ElevatedButton(
            onPressed: () async {
              if (_currentPage < _tutorialData.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
              } else {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('has_seen_onboarding', true);

                if (mounted) context.go('/home');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: VedaTheme.brandGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _currentPage < _tutorialData.length - 1 ? 'Next' : 'Start', 
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}