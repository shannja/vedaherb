import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:vedaherb/core/theme.dart';
import 'package:vedaherb/features/session/application/all_sessions_controller.dart';
import 'package:vedaherb/features/session/application/language_service.dart';
import 'package:vedaherb/features/session/application/session_controller.dart';
import 'package:vedaherb/features/session/domain/models.dart';
import 'package:vedaherb/features/session/presentation/widgets/input_bar.dart';
import 'package:vedaherb/features/session/presentation/widgets/message_bubble.dart';
import 'package:vedaherb/features/session/presentation/widgets/session_header.dart';

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
  final FocusNode _titleFocusNode = FocusNode();

  late final String _sessionId;
  late final LanguageService _languageService;

  bool _isDisposed = false;
  bool _initialized = false;
  bool _isGenerating = false;
  StreamSubscription? _generationSubscription;

  @override
  void initState() {
    super.initState();
    _sessionId = widget.sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();
    _languageService = LanguageService();

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

    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeSession());
  }

  void _initializeSession() async {
    if (_initialized) return;
    _initialized = true;

    var allSessions = ref.read(allSessionsControllerProvider).asData?.value;
    allSessions ??= await ref.read(allSessionsControllerProvider.future);
    final existing = allSessions?[_sessionId];

    if (existing != null) {
      _titleController.text = existing.title;
      ref.read(sessionMessagesProvider(_sessionId).notifier).setAll(List.from(existing.messages));
      ref.read(sessionIdentifiedPlantProvider(_sessionId).notifier).setPlant(existing.identifiedPlant);
      ref.read(sessionStateProviderFamily(_sessionId).notifier).setStateValue(existing.currentState);
      _transitionController.value = existing.currentState == SessionState.cameraFullscreen ? 0.0 : 1.0;
    } else {
      _titleController.text = widget.entryPoint == SessionEntryPoint.camera
          ? "Garden Scan - ${DateTime.now().toString().substring(0, 10)}"
          : "Symptom Chat - ${DateTime.now().toString().substring(0, 10)}";

      if (widget.entryPoint == SessionEntryPoint.chat) {
        ref.read(sessionStateProviderFamily(_sessionId).notifier).setStateValue(SessionState.chatting);
        _transitionController.value = 1.0;
        _addVedaMessage("Hello! Tell me how you're feeling today. Describe your symptoms and I'll help find the right herbal remedy.");
        _saveSession();
      } else {
        if (mounted && !_isDisposed) setState(() {});
        await _captureHerbImage();
      }
    }

    final loaded = await _languageService.load();
    if (mounted) setState(() {});
    debugPrint('Gemma loaded: $loaded');
  }

  Future<void> _saveSession() async {
    if (_isDisposed || !mounted) return;
    try {
      final messages = ref.read(sessionMessagesProvider(_sessionId));
      final plant = ref.read(sessionIdentifiedPlantProvider(_sessionId));
      final sessionState = ref.read(sessionStateProviderFamily(_sessionId));
      final titleText = _titleController.text.trim();
      final title = titleText.isNotEmpty ? titleText : "Session ${_sessionId.substring(0, 5)}";

      final sessionsState = ref.read(allSessionsControllerProvider);
      if (sessionsState is! AsyncData<Map<String, SessionData>>) return;

      final existingSession = sessionsState.value[_sessionId];
      await ref.read(allSessionsControllerProvider.notifier).saveSession(
        SessionData(
          sessionId: _sessionId,
          title: title,
          entryPoint: widget.entryPoint,
          messages: messages,
          identifiedPlant: plant,
          currentState: sessionState,
          createdAt: existingSession?.createdAt ?? DateTime.now(),
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('Save error: $e');
    }
  }

  void _addMessage(SessionChatMessage message) {
    if (_isDisposed) return;
    ref.read(sessionMessagesProvider(_sessionId).notifier).add(message);
    _scrollToBottom();
    _saveSession();
  }

  void _addVedaMessage(String text) {
    _addMessage(SessionChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _sendMessage() async {
    if (_isDisposed || _isGenerating) return;

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _addMessage(SessionChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _textController.clear();

    if (!_languageService.isLoaded) {
      _addVedaMessage("Veda is warming up. Please wait a moment...");
      return;
    }

    setState(() => _isGenerating = true);

    final aiMsgId = DateTime.now().millisecondsSinceEpoch.toString();
    ref.read(sessionMessagesProvider(_sessionId).notifier).add(SessionChatMessage(
      id: aiMsgId,
      text: 'Veda is thinking...',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    _scrollToBottom();

    final history = ref.read(sessionMessagesProvider(_sessionId));
    final buffer = StringBuffer();
    bool isFirstToken = true;

    _generationSubscription = _languageService.generate(
      userMessage: text,
      history: history,
    ).listen(
      (token) {
        if (_isDisposed) return;
        if (isFirstToken) {
          isFirstToken = false;
          buffer.clear();
        }
        buffer.write(token);

        final msgs = ref.read(sessionMessagesProvider(_sessionId));
        ref.read(sessionMessagesProvider(_sessionId).notifier).setAll(
          msgs.map((m) => m.id == aiMsgId
              ? m.copyWith(text: buffer.toString())
              : m).toList(),
        );
        _scrollToBottom();
      },
      onDone: () {
        if (!_isDisposed) setState(() => _isGenerating = false);
        _saveSession();
      },
      onError: (e) {
        debugPrint('Generation error: $e');
        if (!_isDisposed) setState(() => _isGenerating = false);
      },
    );
  }

  Future<void> _captureHerbImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (xFile == null) {
      if (mounted) setState(() {});
      return;
    }

    final storedPath = await _persistPickedImage(xFile);
    if (storedPath != null) {
      _addMessage(SessionChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        localImagePath: storedPath,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      if (mounted) setState(() {});
      _transitionToChat("Lagundi");
    }
  }

  Future<String?> _persistPickedImage(XFile xFile) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/session_media/$_sessionId');
      if (!await dir.exists()) await dir.create(recursive: true);
      final destPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${xFile.name}';
      await File(destPath).writeAsBytes(await xFile.readAsBytes(), flush: true);
      return destPath;
    } catch (e) {
      return null;
    }
  }

  Future<void> _transitionToChat(String plantName) async {
    ref.read(sessionIdentifiedPlantProvider(_sessionId).notifier).setPlant(plantName);
    ref.read(sessionStateProviderFamily(_sessionId).notifier).setStateValue(SessionState.transitioning);
    await _transitionController.forward();
    ref.read(sessionStateProviderFamily(_sessionId).notifier).setStateValue(SessionState.chatting);
    _addMessage(SessionChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "🌿 Identified: $plantName",
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.plantResult,
    ));
    _addVedaMessage("I found $plantName. This herb is commonly used in traditional medicine. What symptoms are you feeling?");
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _generationSubscription?.cancel();
    _languageService.dispose();
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
    final showCameraLayer = widget.entryPoint == SessionEntryPoint.camera &&
        (sessionState == SessionState.cameraFullscreen ||
            sessionState == SessionState.transitioning);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (showCameraLayer)
            SlideTransition(position: _cameraSlideAnimation),
          SlideTransition(
            position: _chatSlideAnimation,
            child: IgnorePointer(
              ignoring: showCameraLayer,
              child: _buildChatView(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatView(bool isDark) {
    final messages = ref.watch(sessionMessagesProvider(_sessionId));

    return Container(
      color: isDark ? VedaTheme.darkBg : VedaTheme.lightBg,
      child: SafeArea(
        child: Column(
          children: [
            SessionHeader(
              isDark: isDark,
              titleController: _titleController,
              titleFocusNode: _titleFocusNode,
              onSave: _saveSession,
              onClose: () async {
                if (_isDisposed || !mounted) return;
                _generationSubscription?.cancel();
                await _saveSession();
                if (mounted) context.pop();
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) => SessionMessageBubble(
                  message: messages[index],
                  isDark: isDark,
                ),
              ),
            ),
            SessionInputBar(
              isDark: isDark,
              controller: _textController,
              onSend: _sendMessage,
              onCameraTap: _captureHerbImage,
            ),
          ],
        ),
      ),
    );
  }
}