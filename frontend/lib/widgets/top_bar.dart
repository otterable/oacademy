// lib/widgets/top_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';
import '../screens/login_screen.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userName; // Added userName parameter
  final bool showMenuIcon;
  final VoidCallback? onMenuPressed;

  const TopBar({
    super.key,
    this.userName,
    this.showMenuIcon = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final locale = languageProvider.locale ?? Localizations.localeOf(context);
    String flagEmoji;

    // Map the locale to a country flag emoji
    switch (locale.languageCode) {
      case 'de':
        flagEmoji = '🇩🇪';
        break;
      case 'en':
      default:
        flagEmoji = '🇬🇧';
    }

    return AppBar(
      backgroundColor: const Color(0xFF003058),
      titleSpacing: 0,
      leading: showMenuIcon
          ? IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: onMenuPressed,
            )
          : null,
      title: Row(
        children: [
          if (!showMenuIcon)
            const SizedBox(width: 8), // Add spacing if no menu icon
          Image.asset(
            'assets/logo.png',
            height: 40,
          ),
          const SizedBox(width: 10),
          Text(
            AppLocalizations.of(context).appTitle,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
      actions: [
        // Language Switcher
        TextButton(
          onPressed: () {
            // Open the language selection menu
            final RenderBox button = context.findRenderObject() as RenderBox;
            final Offset offset = button.localToGlobal(Offset.zero);

            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                offset.dx + button.size.width - 200,
                kToolbarHeight,
                16,
                0,
              ),
              items: [
                PopupMenuItem<String>(
                  value: 'en',
                  child: const Text('🇬🇧 English'),
                  onTap: () {
                    languageProvider.setLocale(const Locale('en'));
                  },
                ),
                PopupMenuItem<String>(
                  value: 'de',
                  child: const Text('🇩🇪 Deutsch'),
                  onTap: () {
                    languageProvider.setLocale(const Locale('de'));
                  },
                ),
              ],
            );
          },
          child: Text(
            flagEmoji,
            style: const TextStyle(
              fontSize: 24,
            ),
          ),
        ),
        if (userName != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Logged in as: $userName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF003058),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).login,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
