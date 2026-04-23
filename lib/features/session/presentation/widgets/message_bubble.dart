import 'dart:io';

import 'package:flutter/material.dart';

import 'package:vedaherb/core/theme.dart';
import 'package:vedaherb/features/session/domain/models.dart';

class SessionMessageBubble extends StatelessWidget {
  const SessionMessageBubble({
    super.key,
    required this.message,
    required this.isDark,
  });

  final SessionChatMessage message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isPlantResult = message.type == MessageType.plantResult;
    final imagePath = message.localImagePath;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: BoxDecoration(
                color: VedaTheme.brandGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 16,
                color: VedaTheme.brandGreen,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? VedaTheme.brandGreen
                    : isPlantResult
                        ? VedaTheme.brandGreen.withValues(alpha: 0.15)
                        : isDark
                            ? Colors.white12
                            : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                border: isPlantResult
                    ? Border.all(
                        color: VedaTheme.brandGreen.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imagePath != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 220,
                          maxHeight: 220,
                        ),
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 220,
                              height: 120,
                              color: message.isUser
                                  ? Colors.white24
                                  : (isDark ? Colors.white10 : Colors.black12),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: message.isUser
                                    ? Colors.white70
                                    : (isDark ? Colors.white54 : Colors.black45),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (message.text.isNotEmpty) const SizedBox(height: 8),
                  ],
                  if (message.text.isNotEmpty)
                    Text(
                      message.text,
                      style: TextStyle(
                        fontFamily: VedaTheme.bodyFont,
                        fontSize: 14,
                        color: message.isUser
                            ? Colors.white
                            : isDark
                                ? Colors.white
                                : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

