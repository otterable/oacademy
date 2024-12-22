// lib/widgets/top_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';
import '../screens/login_screen.dart';
import '../utils/storage_helper.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userName;
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
    String flagEmoji = locale.languageCode == 'de' ? '🇩🇪' : '🇬🇧';

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
            const SizedBox(width: 8),
          Image.asset('assets/logo.png', height: 40),
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
            // Show your language popup if needed
          },
          child: Text(
            flagEmoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        if (userName != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Row(
                children: [
                  Text(
                    'Logged in as: $userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () async {
                      // Clear the token
                      await StorageHelper.saveToken(null);
                      // Go back to login screen
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF003058),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
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
            ),
            child: Text(
              AppLocalizations.of(context).login,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

