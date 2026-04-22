import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:vedaherb/core/theme.dart';
import 'package:vedaherb/features/session/application/all_sessions_controller.dart';
import 'package:vedaherb/features/session/domain/models.dart';

// --- Models ---

enum SessionStatus { active, resolved, escalated }

enum SessionEntryType { camera, chat, both }

class SessionCard {
  final String id;
  final String title;
  final SessionStatus status;
  final SessionEntryType entryType;
  final DateTime createdAt;

  const SessionCard({
    required this.id,
    required this.title,
    required this.status,
    required this.entryType,
    required this.createdAt,
  });
}

// --- Providers ---

final activeFilterProvider =
    NotifierProvider<ActiveFilterNotifier, SessionStatus?>(
      ActiveFilterNotifier.new,
    );

class ActiveFilterNotifier extends Notifier<SessionStatus?> {
  @override
  SessionStatus? build() => null;

  void setFilter(SessionStatus? next) => state = next;
}

// --- Dial Config ---

// Configuration for speed dial items
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

// --- Screen ---
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

  final ScrollController _scrollController = ScrollController();

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

  // Speed dial menu items
  List<DialConfig> get _dialItems => [
    DialConfig(
      label: "Emergency",
      icon: Icons.emergency_rounded,
      color: VedaTheme.dangerRed,
      onTap: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please call for medical assistance now."),
            duration: const Duration(seconds: 3),
            backgroundColor: VedaTheme.dangerRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
          ),
        );
      },
    ),
    DialConfig(
      label: "I have symptoms",
      icon: Icons.chat_bubble_rounded,
      color: VedaTheme.warningYellow,
      onTap: () async {
        if (!mounted) return;
        final newSessionId = DateTime.now().millisecondsSinceEpoch.toString();
        await _createSessionPlaceholder(
          sessionId: newSessionId,
          entryPoint: SessionEntryPoint.chat,
        );
        if (!mounted) return;
        context.push('/session/$newSessionId', extra: SessionEntryPoint.chat);
      },
    ),
    DialConfig(
      label: "Scan for herbs",
      icon: Icons.camera_alt_rounded,
      color: VedaTheme.brandGreen,
      onTap: () {
        if (mounted) {
          _closeFab();
          _startDirectHerbScan();
        }
      },
    ),
  ];

  Future<void> _startDirectHerbScan() async {
    if (!mounted) return;

    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xFile == null || !mounted) return;

    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final storedPath = await _persistPickedImage(xFile, sessionId);
    if (storedPath == null || !mounted) return;

    final now = DateTime.now();
    final initialMessages = [
      ChatMessage(
        id: now.millisecondsSinceEpoch.toString(),
        localImagePath: storedPath,
        isUser: true,
        timestamp: now,
      ),
    ];

    final session = SessionData(
      sessionId: sessionId,
      title: "Garden Scan - ${now.toString().substring(0, 10)}",
      entryPoint: SessionEntryPoint.chat,
      messages: initialMessages,
      identifiedPlant: null,
      currentState: SessionState.chatting,
      createdAt: now,
      lastUpdated: now,
    );

    await ref.read(allSessionsControllerProvider.notifier).saveSession(session);
    if (!mounted) return;
    context.push('/session/$sessionId', extra: SessionEntryPoint.chat);
  }

  Future<String?> _persistPickedImage(XFile xFile, String sessionId) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/session_media/$sessionId');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final originalName = xFile.name;
      final safeSuffix = originalName.trim().isEmpty
          ? 'image.jpg'
          : originalName;
      final destPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_$safeSuffix';

      final bytes = await xFile.readAsBytes();
      final out = File(destPath);
      await out.writeAsBytes(bytes, flush: true);
      return out.path;
    } catch (e, st) {
      debugPrint('Failed to persist herb scan image: $e\n$st');
      return null;
    }
  }

  Future<void> _editSessionTitle(String sessionId, String currentTitle, bool isDark) async {
    if (!mounted) return;

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        var localText = currentTitle;
        final controller = TextEditingController(text: currentTitle);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit session title', style: TextStyle(fontFamily: VedaTheme.titleFont, fontWeight: FontWeight.bold, fontSize: 18)),
              backgroundColor: isDark ? VedaTheme.darkBg : VedaTheme.lightBg,
              content: TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                  ),
                ),
                onChanged: (v) => localText = v,
                onSubmitted: (_) => Navigator.of(context).pop(localText.trim()),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: VedaTheme.bodyFont,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(localText.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VedaTheme.brandGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: VedaTheme.titleFont,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (newTitle == null || !mounted) return;
    final trimmedTitle = newTitle.trim();
    if (trimmedTitle.isEmpty) return;

    final sessionsState = ref.read(allSessionsControllerProvider);
    if (sessionsState is! AsyncData<Map<String, SessionData>>) return;

    final existingSession = sessionsState.value[sessionId];
    if (existingSession == null) return;

    try {
      await ref
          .read(allSessionsControllerProvider.notifier)
          .saveSession(
            existingSession.copyWith(
              title: trimmedTitle,
              lastUpdated: DateTime.now(),
            ),
          );
    } catch (e) {
      debugPrint('Failed to save session title: $e');
    }
  }

  Future<void> _createSessionPlaceholder({
    required String sessionId,
    required SessionEntryPoint entryPoint,
  }) async {
    final now = DateTime.now();
    final initialMessages = entryPoint == SessionEntryPoint.chat
        ? [
            ChatMessage(
              id: now.millisecondsSinceEpoch.toString(),
              text:
                  "Hello! Tell me how you're feeling today. Describe your symptoms and I'll help find the right herbal remedy.",
              isUser: false,
              timestamp: now,
            ),
          ]
        : const <ChatMessage>[];

    final session = SessionData(
      sessionId: sessionId,
      title: entryPoint == SessionEntryPoint.camera
          ? "Garden Scan - ${now.toString().substring(0, 10)}"
          : "Symptom Chat - ${now.toString().substring(0, 10)}",
      entryPoint: entryPoint,
      messages: initialMessages,
      identifiedPlant: null,
      currentState: entryPoint == SessionEntryPoint.camera
          ? SessionState.cameraFullscreen
          : SessionState.chatting,
      createdAt: now,
      lastUpdated: now,
    );

    await ref.read(allSessionsControllerProvider.notifier).saveSession(session);
  }

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
    _scrollController.dispose();
    super.dispose();
  }

  List<SessionCard> _filteredSessions(
    List<SessionCard> sessions,
    SessionStatus? filter,
  ) {
    if (filter == null) return sessions;
    return sessions.where((s) => s.status == filter).toList();
  }

  SessionCard _toCard(SessionData session) {
    final status = switch (session.currentState) {
      SessionState.resolved => SessionStatus.resolved,
      SessionState.escalating => SessionStatus.escalated,
      _ => SessionStatus.active,
    };

    final entryType = switch (session.entryPoint) {
      SessionEntryPoint.camera => SessionEntryType.camera,
      SessionEntryPoint.chat => SessionEntryType.chat,
    };

    return SessionCard(
      id: session.sessionId,
      title: session.title,
      status: status,
      entryType: entryType,
      createdAt: session.createdAt,
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionsMap =
        ref.watch(allSessionsControllerProvider).asData?.value ?? {};
    final sessions = sessionsMap.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final activeFilter = ref.watch(activeFilterProvider);
    final cards = sessions.map(_toCard).toList();
    final filtered = _filteredSessions(cards, activeFilter);
    final isEmpty = cards.isEmpty;

    return Scaffold(
      backgroundColor: isDark ? VedaTheme.darkBg : VedaTheme.lightBg,
      body: SafeArea(
        child: Stack(
          children: [
            /// Main Content
            if (isEmpty)
              /// Empty State - Only settings button and illustration
              Column(
                children: [
                  /// Settings button only (no title, no pills)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
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
                            Icons.settings_rounded,
                            size: 22,
                            color: VedaTheme.brandGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "Click the + button below to start.",
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              /// Sessions exist - Show sticky header with sessions list
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  /// Sticky Header (Settings, Title, Pills)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyHeaderDelegate(
                      isDark: isDark,
                      activeFilter: activeFilter,
                      onFilterChanged: (filter) {
                        ref
                            .read(activeFilterProvider.notifier)
                            .setFilter(filter);
                      },
                      onSettingsTap: () => context.push('/settings'),
                    ),
                  ),

                  /// Session cards
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final session = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildSessionCard(session, isDark),
                        );
                      }, childCount: filtered.length),
                    ),
                  ),

                  /// Bottom padding
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              ),

            /// Scrim overlay
            if (_isOpen)
              GestureDetector(
                onTap: _closeFab,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      color: (isDark ? VedaTheme.darkBg : VedaTheme.lightBg)
                          .withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),

            /// Speed Dial FAB
            Positioned(
              bottom: 30,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      if (!_isOpen) return const SizedBox.shrink();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ..._dialItems.reversed.toList().asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final item = entry.value;
                            final delay = index * 0.15;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildDialItem(config: item, delay: delay),
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

  // Builds a session card with swipe-to-delete
  Widget _buildSessionCard(SessionCard session, bool isDark) {
    final statusColor = switch (session.status) {
      SessionStatus.active => VedaTheme.brandGreen,
      SessionStatus.resolved => Colors.grey,
      SessionStatus.escalated => VedaTheme.dangerRed,
    };

    final statusLabel = switch (session.status) {
      SessionStatus.active => "Active",
      SessionStatus.resolved => "Resolved",
      SessionStatus.escalated => "Escalated",
    };

    final statusIcon = switch (session.status) {
      SessionStatus.active => Icons.radio_button_checked_rounded,
      SessionStatus.resolved => Icons.check_circle_rounded,
      SessionStatus.escalated => Icons.warning_rounded,
    };

    final entryIcons = switch (session.entryType) {
      SessionEntryType.camera => [Icons.camera_alt_rounded],
      SessionEntryType.chat => [Icons.chat_bubble_rounded],
      SessionEntryType.both => [
          Icons.camera_alt_rounded,
          Icons.chat_bubble_rounded,
        ],
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Dismissible(
        key: Key(session.id),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            await _editSessionTitle(session.id, session.title, isDark);
            return false;
          } else if (direction == DismissDirection.endToStart) {
            return true;
          }
          return false;
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            ref
                .read(allSessionsControllerProvider.notifier)
                .removeSession(session.id);
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${session.title} deleted"),
                duration: const Duration(seconds: 3),
                backgroundColor: VedaTheme.brandGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
            );
          }
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          color: statusColor,
          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 28),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          color: VedaTheme.dangerRed,
          child: const Icon(
            Icons.delete_sweep_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            final entryPoint = session.entryType == SessionEntryType.camera
                ? SessionEntryPoint.camera
                : SessionEntryPoint.chat;
            context.push('/session/${session.id}', extra: entryPoint);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, size: 22, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontFamily: VedaTheme.titleFont,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...entryIcons.map(
                            (icon) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                icon,
                                size: 12,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.black38,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _timeAgo(session.createdAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontFamily: VedaTheme.bodyFont,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialItem({required DialConfig config, required double delay}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final offsetAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
          ),
        );

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

// Sticky Header Delegate
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  final SessionStatus? activeFilter;
  final Function(SessionStatus?) onFilterChanged;
  final VoidCallback onSettingsTap;

  _StickyHeaderDelegate({
    required this.isDark,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onSettingsTap,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? VedaTheme.darkBg : VedaTheme.lightBg,
      padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Settings button
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onSettingsTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: VedaTheme.brandGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.settings_rounded,
                  size: 22,
                  color: VedaTheme.brandGreen,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// Page title
          Text("Sessions", style: Theme.of(context).textTheme.headlineLarge),

          const SizedBox(height: 12),

          /// Filter pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPill(
                  label: "All",
                  isActive: activeFilter == null,
                  onTap: () => onFilterChanged(null),
                  isDark: isDark,
                ),  
                const SizedBox(width: 8),
                _buildPill(
                  label: "Active",
                  isActive: activeFilter == SessionStatus.active,
                  onTap: () => onFilterChanged(SessionStatus.active),
                  isDark: isDark,
                  color: VedaTheme.brandGreen,
                ),
                const SizedBox(width: 8),
                _buildPill(
                  label: "Resolved",
                  isActive: activeFilter == SessionStatus.resolved,
                  onTap: () => onFilterChanged(SessionStatus.resolved),
                  isDark: isDark,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                _buildPill(
                  label: "Escalated",
                  isActive: activeFilter == SessionStatus.escalated,
                  onTap: () => onFilterChanged(SessionStatus.escalated),
                  isDark: isDark,
                  color: VedaTheme.dangerRed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
    Color? color,
  }) {
    final activeColor = color ?? VedaTheme.brandGreen;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.15)
              : isDark
              ? Colors.white12
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: 0.5)
                : isDark
                ? Colors.white12
                : Colors.black12,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: VedaTheme.bodyFont,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
            color: isActive
                ? activeColor
                : isDark
                ? Colors.white70
                : Colors.black54,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 160;

  @override
  double get minExtent => 160;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return isDark != oldDelegate.isDark ||
        activeFilter != oldDelegate.activeFilter;
  }
}
