import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:vedaherb/core/theme.dart';

class DialConfig {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DialConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  List<DialConfig> get _dialItems => [
    DialConfig(
      label: "Emergency",
      icon: Icons.emergency_rounded,
      color: VedaTheme.dangerRed,
      onTap: () => debugPrint("Emergency Pressed"),
    ),
    DialConfig(
      label: "I have symptoms",
      icon: Icons.chat_bubble_rounded,
      color: VedaTheme.warningYellow,
      onTap: () => debugPrint("Symptoms Pressed"),
    ),
    DialConfig(
      label: "Scan your garden",
      icon: Icons.camera_alt_rounded,
      color: VedaTheme.brandGreen,
      onTap: () => debugPrint("Scan Pressed"),
    ),
  ];

  void _toggleFab() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _controller.forward() : _controller.reverse();
  }

  void _closeFab() {
    setState(() => _isOpen = false);
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? VedaTheme.darkBg : VedaTheme.lightBg,
      body: SafeArea(
        child: Stack(
          children: [
            /// 1. Main Content
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      isDark
                          ? 'assets/images/illustrations/states/empty-dark.png'
                          : 'assets/images/illustrations/states/empty-light.png',
                      width: 250,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Nothing yet",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Click the + button below to start.",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            /// Settings FAB — top right corner
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => context.push('/settings'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: VedaTheme.brandGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 22,
                    color: VedaTheme.brandGreen,
                  ),
                ),
              ),
            ),

            /// 2. Scrim overlay
            if (_isOpen)
              GestureDetector(
                onTap: _closeFab,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 8.0,
                        sigmaY: 8.0,
                      ),
                      child: Container(
                      // Use the theme background color with a slight transparency
                      color: (Theme.of(context).brightness == Brightness.dark 
                          ? VedaTheme.darkBg 
                          : VedaTheme.lightBg).withValues(alpha: 0.85),
                    ),
                    ),
                ),
              ),

            /// 3. Speed Dial FAB
            Positioned(
              bottom: 30,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  /// Dial items
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      if (!_isOpen) return const SizedBox.shrink();
                      
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          /// Reversed so bottom item animates first
                         ..._dialItems.reversed.toList().asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final delay = index * 0.15;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildDialItem(
                                config: item,
                                delay: delay,
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                  
                  GestureDetector(
                    onTap: _toggleFab,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: VedaTheme.brandGreen,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: VedaTheme.brandGreen.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: AnimatedRotation(
                        turns: _isOpen ? 0.125 : 0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: const Icon(
                          Icons.add_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialItem({
    required DialConfig config,
    required double delay,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
    ));

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, 1.0, curve: Curves.easeIn),
      ),
      child: SlideTransition(
        position: offsetAnimation,
        child: GestureDetector(
          onTap: () {
            config.onTap();
            _closeFab();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Label chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  config.label,
                  style: TextStyle(
                    fontFamily: VedaTheme.bodyFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// Icon button — uses config.color ✅
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: config.color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: config.color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(config.icon, size: 22, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}