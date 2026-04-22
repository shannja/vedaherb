import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vedaherb/core/theme.dart';

import 'package:vedaherb/features/settings/application/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsControllerProvider).asData?.value;
    final themeMode = settings?.themeMode ?? ThemeMode.light;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: isDark ? VedaTheme.darkBg : VedaTheme.lightBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            /// Back button — now scrolls with content
            Align(
              alignment: Alignment.centerRight,
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
                    size: 22,
                    color: VedaTheme.brandGreen,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
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
                  ref.read(settingsControllerProvider.notifier).setThemeMode(next);
                },
                style: _buttonStyle(isDark),
                child: Text(
                  _getThemeLabel(themeMode),
                  style: textTheme.headlineSmall?.copyWith(color: VedaTheme.brandGreen),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            _buildSettingTile(
              isDark: isDark,
              icon: Icons.language,
              label: "Language",
              textTheme: textTheme,
              trailing: _buildDropdown(
                isDark: isDark,
                currentValue: settings?.language ?? 'English',
                options: ["English", "Filipino"],
                textTheme: textTheme,
                onSelected: (val) {
                  if (val != null) {
                    ref.read(settingsControllerProvider.notifier).setLanguage(val);
                  }
                }
              ),
            ),
            
            // const SizedBox(height: 32),
            // /// --- Notifications ---
            // Text("Notifications", style: textTheme.headlineLarge),
            // const SizedBox(height: 16),
            // _buildSettingTile(
            //   isDark: isDark,
            //   icon: (settings?.notificationsEnabled ?? true)
            //       ? Icons.notifications_active_rounded
            //       : Icons.notifications_off_rounded,
            //   label: "Check-ins",
            //   subtitle: "Monitoring reminders",
            //   textTheme: textTheme,
            //   trailing: Switch.adaptive(
            //     value: settings?.notificationsEnabled ?? true,
            //     onChanged: (val) {
            //       ref
            //           .read(settingsControllerProvider.notifier)
            //           .setNotificationsEnabled(val);
            //     },
            //     activeThumbColor: VedaTheme.brandGreen,
            //     inactiveTrackColor: VedaTheme.brandGreen.withValues(alpha: 0.3),
            //     inactiveThumbColor: VedaTheme.brandGreen.withValues(alpha: 0.7),
            //     trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            //   ),
            // ),

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
                style: _buttonStyle(isDark),
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
                style: _buttonStyle(isDark),
                child: const Icon(Icons.arrow_outward, size: 18, color: VedaTheme.brandGreen),
              ),
            ),
            
            const SizedBox(height: 12),
            _buildSettingTile(
              isDark: isDark,
              icon: Icons.privacy_tip_rounded,
              label: "Privacy Policy",
              subtitle: "Data policies",
              textTheme: textTheme,
              trailing: TextButton(
                onPressed: () => debugPrint("ToS Clicked"),
                style: _buttonStyle(isDark),
                child: const Icon(Icons.arrow_outward, size: 18, color: VedaTheme.brandGreen),
              ),
            ),
            
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: VedaTheme.bodyFont,
                      fontWeight: FontWeight.normal,
                      color: isDark 
                          ? const Color.fromARGB(87, 255, 255, 255) 
                          : const Color.fromARGB(128, 0, 0, 0),
                    ),
                children: [
                  const TextSpan(text: "Offline AI ", style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: "cross-references your herb pantry and mild symptoms with "),
                  const TextSpan(text: "government health reports ", style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: "to suggest remedies.\n\n"),
                  const TextSpan(text: "For educational use only. ", style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: "Veda must not be used for official diagnosis or medical advice.\n\n"),
                  const TextSpan(text: "Always consult a healthcare professional for severe health concerns."),
                ],
              ),
              textAlign: TextAlign.left,
            ),

            const SizedBox(height: 32),
            /// --- Sync ---
            Text("Data & privacy", style: textTheme.headlineLarge),
            const SizedBox(height: 16),
            _buildSettingTile(
              isDark: isDark,
              icon: Icons.storage_rounded,
              label: "Clear Data",
              iconColor: VedaTheme.dangerRed,
              subtitle: "Delete all data and preferences",
              textTheme: textTheme,
              trailing: TextButton(
                onPressed: () async {
                  // Show confirmation dialog
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Clear Data', style: TextStyle(fontFamily: VedaTheme.titleFont, fontWeight: FontWeight.bold, fontSize: 18)),
                      backgroundColor: isDark ? VedaTheme.darkBg : VedaTheme.lightBg,
                      content: Text.rich(
                        TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontFamily: VedaTheme.bodyFont,
                                fontWeight: FontWeight.normal,
                                color: isDark 
                                    ? const Color.fromARGB(200, 255, 255, 255) 
                                    : const Color.fromARGB(200, 0, 0, 0),
                              ),
                          children: [
                            const TextSpan(text: "All of your data will be deleted.\n\nIf you are signed in,\n"),
                            const TextSpan(text: "synced data will also be deleted.\n\n", style: TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: "The app will restart."),
                            const TextSpan(text: " Continue?", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontFamily: VedaTheme.bodyFont)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(
                            backgroundColor: VedaTheme.dangerRed,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Yes, Delete', style: TextStyle(fontFamily: VedaTheme.titleFont, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirmed != true) return;
                  
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  
                  // This will fully restart your app
                  Restart.restartApp();
                },
                style: _buttonStyle(isDark),
                child: const Icon(Icons.clear_rounded, size: 18, color: VedaTheme.dangerRed),
              ),
            ),
            // _buildSettingTile(
            //   isDark: isDark,
            //   icon: Icons.person_rounded,
            //   label: "Sign in",
            //   subtitle: "Access across devices",
            //   textTheme: textTheme,
            //   trailing: TextButton(
            //     onPressed: () => debugPrint("ToS Clicked"),
            //     style: _buttonStyle(),
            //     child: const Icon(Icons.login_rounded, size: 18, color: VedaTheme.brandGreen),
            //   ),
            // ),
            // 
            // const SizedBox(height: 16),
            // _buildSettingTile(
            //   isDark: isDark,
            //   icon: (settings?.anonymousUsageEnabled ?? false)
            //       ? Icons.report_rounded
            //       : Icons.report_off_rounded,
            //   label: "Health reports",
            //   subtitle: "Send trends data",
            //   textTheme: textTheme,
            //   trailing: Switch.adaptive(
            //     value: settings?.anonymousUsageEnabled ?? false,
            //     onChanged: (val) {
            //       ref
            //           .read(settingsControllerProvider.notifier)
            //           .setAnonymousUsageEnabled(val);
            //     },
            //     activeThumbColor: VedaTheme.brandGreen,
            //     inactiveTrackColor: VedaTheme.brandGreen.withValues(alpha: 0.3),
            //     inactiveThumbColor: VedaTheme.brandGreen.withValues(alpha: 0.7),
            //     trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            //   ),
            // ),
            // 
            // const SizedBox(height: 12),
            // Text.rich(
            //   TextSpan(
            //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
            //           fontFamily: VedaTheme.bodyFont,
            //           fontWeight: FontWeight.normal,
            //           color: isDark 
            //               ? const Color.fromARGB(87, 255, 255, 255) 
            //               : const Color.fromARGB(128, 0, 0, 0),
            //         ),
            //     children: [
            //       const TextSpan(text: "Signing in is used "),
            //       const TextSpan(text: "exclusively ", style: TextStyle(fontWeight: FontWeight.bold)),
            //       const TextSpan(text: "for syncing your monitoring history across devices.\n\n"),
            //       const TextSpan(text: "Health reports are "),
            //       const TextSpan(text: "opt-in only. ", style: TextStyle(fontWeight: FontWeight.bold)),
            //       const TextSpan(text: "It is anonymous and trends will only be contributed, "),
            //       const TextSpan(text: "never ", style: TextStyle(fontWeight: FontWeight.bold)),
            //       const TextSpan(text: "your identity, location, or personal details.\n\n"),
            //       const TextSpan(text: "Veda "),
            //       const TextSpan(text: "does not sell ", style: TextStyle(fontWeight: FontWeight.bold)),
            //       const TextSpan(text: "personal data or "),
            //       const TextSpan(text: "track activity ", style: TextStyle(fontWeight: FontWeight.bold)),
            //       const TextSpan(text: "for advertising.\n\n"),
            //       const TextSpan(text: "Please check our privacy policy button above for more details or "),
            //       TextSpan(
            //         text: "click here",
            //         style: const TextStyle(
            //           fontWeight: FontWeight.bold,
            //           decoration: TextDecoration.underline, 
            //           decorationColor: VedaTheme.brandGreen,
            //           decorationThickness: 1.5,
            //           color: VedaTheme.brandGreen,
            //         ),
            //         recognizer: TapGestureRecognizer()
            //           ..onTap = () {
            //             debugPrint("Link clicked!");
            //           },
            //       ),
            //       const TextSpan(text: ".\n\n")
            //     ],
            //   ),
            //   textAlign: TextAlign.left,
            // ),
          ],
        ),
      )
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
  ButtonStyle _buttonStyle(bool isDark) => TextButton.styleFrom(
    backgroundColor: isDark ? VedaTheme.darkBg.withValues(alpha: 0.25) : VedaTheme.lightBg,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    // horizontal padding allows text to breathe; 0 padding for icons makes them square
    padding: const EdgeInsets.symmetric(horizontal: 12), 
    minimumSize: const Size(36, 36), // Minimum is a 36x36 square
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  Widget _buildDropdown({
    required String currentValue,
    required List<String> options,
    required ValueChanged<String?> onSelected,
    required TextTheme textTheme,
    required bool isDark,
  }) {
    return MenuAnchor(
      style: MenuStyle(
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        backgroundColor: WidgetStateProperty.fromMap({
          WidgetState.any: isDark ? VedaTheme.darkBg : VedaTheme.lightBg,
        }),
      ),
      builder: (context, controller, child) {
        return TextButton(
          onPressed: () {
            if (controller.isOpen) { controller.close(); }
            else { controller.open(); }
          },
          style: _buttonStyle(isDark),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(currentValue, style: textTheme.headlineSmall?.copyWith(color: VedaTheme.brandGreen)),
              const SizedBox(width: 6),
              ...controller.isOpen
                  ? [Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: VedaTheme.brandGreen)]
                  : [Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: VedaTheme.brandGreen)],
            ],
          ),
        );
      },
      menuChildren: options.map((String value) {
        final isSelected = value == currentValue;
        
        return MenuItemButton(
          onPressed: () => onSelected(value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? VedaTheme.brandGreen
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

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