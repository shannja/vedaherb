import 'package:flutter/material.dart';

import 'package:vedaherb/core/theme.dart';

class SessionInputBar extends StatelessWidget {
  const SessionInputBar({
    super.key,
    required this.isDark,
    required this.controller,
    required this.onSend,
    required this.onCameraTap,
  });

  final bool isDark;
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? VedaTheme.darkBg : VedaTheme.lightBg,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: VedaTheme.brandGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onCameraTap,
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 18,
                  color: VedaTheme.brandGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: VedaTheme.brandGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                style: TextStyle(
                  fontFamily: VedaTheme.bodyFont,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Describe your symptoms...",
                  hintStyle: TextStyle(
                    fontFamily: VedaTheme.bodyFont,
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: VedaTheme.brandGreen,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onSend,
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.arrow_upward_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

