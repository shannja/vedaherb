import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vedaherb/core/theme.dart';
import 'package:vedaherb/main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: isDark ? VedaTheme.darkBg : VedaTheme.lightBg,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                const SizedBox(height: 48),

                /// --- Appearance ---
                Text("Appearance", style: textTheme.headlineLarge),
                const SizedBox(height: 16),
                _buildSettingTile(
                  isDark: isDark,
                  icon: _getThemeIcon(themeMode),
                  label: "Theme",
                  textTheme: textTheme,
                  trailing: TextButton(
                    onPressed: () {
                      ThemeMode next;
                      if (themeMode == ThemeMode.system) {
                        next = ThemeMode.light;
                      } else if (themeMode == ThemeMode.light) {
                        next = ThemeMode.dark;
                      } else {
                        next = ThemeMode.system;
                      }
                      ref.read(themeProvider.notifier).state = next;
                    },
                    style: _buttonStyle(),
                    child: Text(
                      _getThemeLabel(themeMode),
                      style: textTheme.headlineSmall?.copyWith(color: VedaTheme.brandGreen),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                /// --- About ---
                Text("About", style: textTheme.headlineLarge),
                const SizedBox(height: 16),
                _buildSettingTile(
                  isDark: isDark,
                  icon: Icons.info,
                  label: "App Version",
                  textTheme: textTheme,
                  trailing: _buildStaticBox(
                    child: Text(
                      "1.0.0",
                      style: textTheme.bodyLarge?.copyWith(
                        color: VedaTheme.brandGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  isDark: isDark,
                  icon: Icons.cloud,
                  label: "Library",
                  subtitle: "Last sync",
                  textTheme: textTheme,
                  trailing: _buildStaticBox(
                    child: Text(
                      "May 2026",
                      style: textTheme.bodyLarge?.copyWith(
                        color: VedaTheme.brandGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  color: isDark ? Colors.white10 : Colors.black12,
                  thickness: 1,
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  isDark: isDark,
                  icon: Icons.warning_rounded,
                  label: "Disclaimer",
                  subtitle: "Safety & limits",
                  textTheme: textTheme,
                  trailing: TextButton(
                    onPressed: () => debugPrint("ToS Clicked"),
                    style: _buttonStyle(),
                    child: const Icon(Icons.arrow_outward, size: 18, color: VedaTheme.brandGreen),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  isDark: isDark,
                  icon: Icons.description_rounded,
                  label: "Terms of Use",
                  subtitle: "User agreement",
                  textTheme: textTheme,
                  trailing: TextButton(
                    onPressed: () => debugPrint("ToS Clicked"),
                    style: _buttonStyle(),
                    child: const Icon(Icons.arrow_outward, size: 18, color: VedaTheme.brandGreen),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  isDark: isDark,
                  icon: Icons.privacy_tip_rounded,
                  label: "Privacy",
                  subtitle: "Data policies",
                  textTheme: textTheme,
                  trailing: TextButton(
                    onPressed: () => debugPrint("ToS Clicked"),
                    style: _buttonStyle(),
                    child: const Icon(Icons.arrow_outward, size: 18, color: VedaTheme.brandGreen),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Local AI cross-references your herb pantry and mild symptoms with government health reports.\n\nFor educational use only; not to use for diagnosis or medical advice.\n\nAlways consult a healthcare professional for severe health concerns.",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: VedaTheme.bodyFont,
                        fontWeight: FontWeight.normal,
                        color: isDark ? const Color.fromARGB(87, 255, 255, 255) : const Color.fromARGB(128, 0, 0, 0),
                      ),
                ),
                const SizedBox(height: 32),

                /// --- Sync ---
                Text("Sync your data", style: textTheme.headlineLarge),
                const SizedBox(height: 16),
                _buildSettingTile(
                  isDark: isDark,
                  icon: Icons.person_rounded,
                  label: "Log in",
                  subtitle: "Access across devices",
                  textTheme: textTheme,
                  trailing: TextButton(
                    onPressed: () => debugPrint("ToS Clicked"),
                    style: _buttonStyle(),
                    child: const Icon(Icons.login_rounded, size: 18, color: VedaTheme.brandGreen),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Syncing is used exclusively for your convenience.\n\nVeda does not sell personal data or track activity for advertising.",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: VedaTheme.bodyFont,
                        fontWeight: FontWeight.normal,
                        color: isDark ? const Color.fromARGB(87, 255, 255, 255) : const Color.fromARGB(128, 0, 0, 0),
                      ),
                ),
              ],
            ),

            /// Fixed Back Button (Top Right)
            Positioned(
              top: 10,
              right: 16,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: VedaTheme.brandGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 18,
                    color: VedaTheme.brandGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required bool isDark,
    required IconData icon,
    required String label,
    String? subtitle,
    Color? iconColor,
    required Widget trailing,
    required TextTheme textTheme,
  }) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VedaTheme.brandGreen.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? VedaTheme.brandGreen, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.headlineSmall,
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          /// Removed the fixed width SizedBox. 
          /// The height is fixed to 36, but width will now hug the content (Square vs Rect)
          SizedBox(
            height: 36, 
            child: trailing,
          ),
        ],
      ),
    );
  }

  /// Helper for static info boxes
  Widget _buildStaticBox({required Widget child}) {
    return Container(
      alignment: Alignment.center,
      child: child,
    );
  }

  /// Button Style derived from VedaTheme logic
  ButtonStyle _buttonStyle() => TextButton.styleFrom(
    backgroundColor: VedaTheme.brandGreen.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    // horizontal padding allows text to breathe; 0 padding for icons makes them square
    padding: const EdgeInsets.symmetric(horizontal: 12), 
    minimumSize: const Size(36, 36), // Minimum is a 36x36 square
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  IconData _getThemeIcon(ThemeMode mode) {
    if (mode == ThemeMode.light) return Icons.light_mode_rounded;
    if (mode == ThemeMode.dark) return Icons.dark_mode_rounded;
    return Icons.brightness_auto_rounded;
  }

  String _getThemeLabel(ThemeMode mode) {
    if (mode == ThemeMode.light) return "Light";
    if (mode == ThemeMode.dark) return "Dark";
    return "System";
  }
}