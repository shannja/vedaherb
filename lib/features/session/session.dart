import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:vedaherb/core/theme.dart';
import 'package:vedaherb/features/session/application/all_sessions_controller.dart';
import 'package:vedaherb/features/session/domain/models.dart';
import 'package:vedaherb/features/session/presentation/widgets/input_bar.dart';
import 'package:vedaherb/features/session/presentation/widgets/message_bubble.dart';

// --- Session-specific State (isolated per session) ---
class SessionMessagesNotifier extends Notifier<List<ChatMessage>> {
  SessionMessagesNotifier(this.sessionId);
  final String sessionId;

  @override
  List<ChatMessage> build() => const [];

  void setAll(List<ChatMessage> next) => state = next;

  void add(ChatMessage message) => state = [...state, message];
}

class SessionIdentifiedPlantNotifier extends Notifier<String?> {
  SessionIdentifiedPlantNotifier(this.sessionId);
  final String sessionId;

  @override
  String? build() => null;

  void setPlant(String? next) => state = next;
}

class SessionStateNotifier extends Notifier<SessionState> {
  SessionStateNotifier(this.sessionId);
  final String sessionId;

  @override
  SessionState build() => SessionState.cameraFullscreen;

  void setStateValue(SessionState next) => state = next;
}

final sessionMessagesProvider = NotifierProvider.family<
    SessionMessagesNotifier,
    List<ChatMessage>,
    String>(SessionMessagesNotifier.new);
final sessionIdentifiedPlantProvider = NotifierProvider.family<
    SessionIdentifiedPlantNotifier,
    String?,
    String>(SessionIdentifiedPlantNotifier.new);
final sessionStateProviderFamily =
    NotifierProvider.family<SessionStateNotifier, SessionState, String>(
  SessionStateNotifier.new,
);

// --- Screen ---

class SessionScreen extends ConsumerStatefulWidget {
  final SessionEntryPoint entryPoint;
  final String? sessionId;

  const SessionScreen({
    super.key,
    required this.entryPoint,
    this.sessionId,
  });

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _transitionController;
  late Animation<Offset> _cameraSlideAnimation;
  late Animation<Offset> _chatSlideAnimation;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isDisposed = false;
  late final FocusNode _titleFocusNode;
  late final String _sessionId;
  bool _initialized = false;
  bool _autoLaunchScanCamera = false;
  
  @override
  void initState() {
    super.initState();
    
    _titleFocusNode = FocusNode();
    _sessionId = widget.sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _cameraSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOutCubic,
    ));

    _chatSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSession();
    });
  }

  void _initializeSession() async {
    if (_initialized) return;
    _initialized = true;
    
    // Check if sessions are already loaded
    var allSessions = ref.read(allSessionsControllerProvider).asData?.value;
    allSessions ??= await ref.read(allSessionsControllerProvider.future);
    final existingSession = allSessions?[_sessionId];
    
    if (existingSession != null) {
      _titleController.text = existingSession.title;
      // Existing session - restore exactly, including current screen state.
      ref
          .read(sessionMessagesProvider(_sessionId).notifier)
          .setAll(List.from(existingSession.messages));
      ref
          .read(sessionIdentifiedPlantProvider(_sessionId).notifier)
          .setPlant(existingSession.identifiedPlant);
      ref
          .read(sessionStateProviderFamily(_sessionId).notifier)
          .setStateValue(existingSession.currentState);
      
      // Match the visual layer to the restored state without animating.
      _transitionController.value =
          existingSession.currentState == SessionState.cameraFullscreen ? 0.0 : 1.0;
    } else {
      // New session
      final defaultTitle = widget.entryPoint == SessionEntryPoint.camera
          ? "Garden Scan - ${DateTime.now().toString().substring(0, 10)}"
          : "Symptom Chat - ${DateTime.now().toString().substring(0, 10)}";
      _titleController.text = defaultTitle;

      if (widget.entryPoint == SessionEntryPoint.chat) {
        // Chat entry - go straight to chat (NO ANIMATION)
        ref
            .read(sessionStateProviderFamily(_sessionId).notifier)
            .setStateValue(SessionState.chatting);
        _transitionController.value = 1.0;
        
        // Add welcome message
        _addGemmaMessage(
          "Hello! Tell me how you're feeling today. Describe your symptoms and I'll help find the right herbal remedy.",
        );
        _saveSession();
      } else {
        // Camera entry - launch the native camera immediately and hide placeholder UI.
        if (mounted && !_isDisposed) {
          setState(() {
            _autoLaunchScanCamera = true;
          });
        }
        await Future<void>.delayed(Duration.zero);
        if (mounted && !_isDisposed) {
          await _captureHerbImage();
        }
      }
    }
  }

  Future<void> _saveSession() async {
    // Triple guard
    if (_isDisposed || !mounted) return;
    
    // Read providers safely inside a try-catch
    try {
      final currentMessages = ref.read(sessionMessagesProvider(_sessionId));
      final currentPlant = ref.read(sessionIdentifiedPlantProvider(_sessionId));
      final currentState = ref.read(sessionStateProviderFamily(_sessionId));
      
      // Check again after async gap
      if (_isDisposed || !mounted) return;

      final titleText = _titleController.text.trim();
      final title = titleText.isNotEmpty
          ? titleText
          : currentPlant != null
              ? "Garden Scan - $currentPlant"
              : "Symptom Chat - ${DateTime.now().toString().substring(0, 10)}";

      final sessionsState = ref.read(allSessionsControllerProvider);
      
      // Only proceed if sessions are loaded
      if (sessionsState is! AsyncData<Map<String, SessionData>>) return;
      
      final existing = sessionsState.value[_sessionId];

      final sessionData = SessionData(
        sessionId: _sessionId,
        title: title,
        entryPoint: widget.entryPoint,
        messages: currentMessages,
        identifiedPlant: currentPlant,
        currentState: currentState,
        createdAt: existing?.createdAt ?? DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      // Final guard before touching providers
      if (_isDisposed || !mounted) return;

      await ref
          .read(allSessionsControllerProvider.notifier)
          .saveSession(sessionData);
          
    } catch (e) {
      debugPrint('Session save skipped: $e');
    }
  }

  Future<void> _transitionToChat(String plantName) async {
    if (mounted && !_isDisposed) {
      ref
          .read(sessionIdentifiedPlantProvider(_sessionId).notifier)
          .setPlant(plantName);
      ref
          .read(sessionStateProviderFamily(_sessionId).notifier)
          .setStateValue(SessionState.transitioning);
    }

    // Animate from camera to chat
    await _transitionController.forward();

    if (mounted && !_isDisposed) {
      ref
          .read(sessionStateProviderFamily(_sessionId).notifier)
          .setStateValue(SessionState.chatting);

      _addMessage(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "🌿 Identified: $plantName",
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.plantResult,
      ));

      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted && !_isDisposed) {
        _addGemmaMessage(
          "I found $plantName in your garden. This herb is commonly used for various ailments. What symptoms are you experiencing?",
        );
        _saveSession();
      }
    }
  }

  void _addMessage(ChatMessage message) {
    if (_isDisposed) return;
    
    final currentMessages = ref.read(sessionMessagesProvider(_sessionId));
    final isDuplicate = currentMessages.any((m) => m.id == message.id);
    if (!isDuplicate) {
      ref.read(sessionMessagesProvider(_sessionId).notifier).add(message);
      _scrollToBottom();
      _saveSession();
    }
  }

  void _addGemmaMessage(String text) {
    _addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _sendMessage() {
    if (_isDisposed) return;
    
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _textController.clear();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && !_isDisposed) {
        _addGemmaMessage(
          "I understand. Based on your symptoms, herbal remedies may help. Would you like me to prepare a monitoring session?",
        );
      }
    });
  }

  Future<void> _onAttachImage() async {
    if (!mounted || _isDisposed) return;

    // Root navigator avoids conflicts with GoRouter's nested navigator.
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: const Text('Take photo'),
                onTap: () =>
                    Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choose from gallery'),
                onTap: () =>
                    Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null || !mounted || _isDisposed) return;

    // Let the sheet close before launching the picker (Android / GoRouter).
    await Future<void>.delayed(Duration.zero);

    if (!mounted || _isDisposed) return;

    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (xFile == null || !mounted || _isDisposed) return;

    final storedPath = await _persistPickedImage(xFile);
    if (storedPath == null || !mounted || _isDisposed) return;

    _addMessage(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        localImagePath: storedPath,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<String?> _persistPickedImage(XFile xFile) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/session_media/$_sessionId');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final originalName = xFile.name;
      final safeSuffix = originalName.trim().isEmpty ? 'image.jpg' : originalName;
      final destPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_$safeSuffix';

      final bytes = await xFile.readAsBytes();
      final out = File(destPath);
      await out.writeAsBytes(bytes, flush: true);
      return out.path;
    } catch (e, st) {
      debugPrint('Failed to persist image: $e\n$st');
      return null;
    }
  }

  void _scrollToBottom() {
    if (_isDisposed) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted && !_isDisposed) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _simulateScan() {
    _captureHerbImage();
  }

  Future<void> _captureHerbImage() async {
    if (!mounted || _isDisposed) return;

    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xFile == null || !mounted || _isDisposed) {
      if (mounted && !_isDisposed) {
        setState(() {
          _autoLaunchScanCamera = false;
        });
      }
      return;
    }

    final storedPath = await _persistPickedImage(xFile);
    if (storedPath == null || !mounted || _isDisposed) {
      if (mounted && !_isDisposed) {
        setState(() {
          _autoLaunchScanCamera = false;
        });
      }
      return;
    }

    _addMessage(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        localImagePath: storedPath,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    // Simulate identification (replace with AI later)
    await Future.delayed(const Duration(seconds: 1));
    if (mounted && !_isDisposed) {
      setState(() {
        _autoLaunchScanCamera = false;
      });
      _transitionToChat("Lagundi");
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _transitionController.dispose();
    _titleController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionState = ref.watch(sessionStateProviderFamily(_sessionId));
    
    // Camera UX: show for herb scan until we transition to chat.
    // Do not require sessionId == null — GoRouter always passes an id from /session/:id.
    final showCameraLayer = widget.entryPoint == SessionEntryPoint.camera &&
        (sessionState == SessionState.cameraFullscreen ||
            sessionState == SessionState.transitioning);

    // Chat is stacked above the camera; when the camera flow is active, ignore
    // pointers on the (often off-screen) chat so shutter/back taps hit the camera.
    final chatIgnoringPointers = showCameraLayer;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera layer - herb scan / identify flow
          if (showCameraLayer)
            SlideTransition(
              position: _cameraSlideAnimation,
            ),

          // Chat layer - always present; slides up after identify
          SlideTransition(
            position: _chatSlideAnimation,
            child: IgnorePointer(
              ignoring: chatIgnoringPointers,
              child: _buildChatView(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatView(bool isDark) {
    final messages = ref.watch(sessionMessagesProvider(_sessionId));
    final identifiedPlant = ref.watch(sessionIdentifiedPlantProvider(_sessionId));

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? VedaTheme.darkBg : VedaTheme.lightBg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IntrinsicWidth(
                            child: TextField(
                              focusNode: _titleFocusNode,
                              controller: _titleController,
                              textInputAction: TextInputAction.done,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontFamily: VedaTheme.titleFont,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Title',
                                hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontFamily: VedaTheme.titleFont,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) {
                                if (!mounted || _isDisposed) return;
                                _saveSession();
                              },
                              onTapOutside: (_) {
                                if (!mounted || _isDisposed) return;
                                FocusScope.of(context).unfocus();
                                _saveSession();
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(_titleFocusNode);
                            },
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 18,
                                color: VedaTheme.brandGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Powered by Gemma · Offline",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: VedaTheme.brandGreen,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      if (_isDisposed || !mounted) return;
                      await _saveSession();
                      if (mounted) context.pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: VedaTheme.brandGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: VedaTheme.brandGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        "Starting session...",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return SessionMessageBubble(
                          message: messages[index],
                          isDark: isDark,
                        );
                      },
                    ),
            ),
            SessionInputBar(
              isDark: isDark,
              controller: _textController,
              onSend: _sendMessage,
              onCameraTap: _onAttachImage,
            ),
          ],
        ),
      ),
    );
  }
}