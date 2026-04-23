import 'package:flutter/material.dart';
import 'package:vedaherb/core/theme.dart';

class SessionHeader extends StatelessWidget {
  const SessionHeader({
    super.key,
    required this.isDark,
    required this.titleController,
    required this.titleFocusNode,
    required this.onSave,
    required this.onClose,
  });

  final bool isDark;
  final TextEditingController titleController;
  final FocusNode titleFocusNode;
  final VoidCallback onSave;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                      focusNode: titleFocusNode,
                      controller: titleController,
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
                      onSubmitted: (_) => onSave(),
                      onTapOutside: (_) {
                        FocusScope.of(context).unfocus();
                        onSave();
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () => FocusScope.of(context).requestFocus(titleFocusNode),
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(
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
            onTap: onClose,
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
    );
  }
}