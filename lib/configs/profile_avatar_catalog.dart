import 'package:flutter/material.dart';

class ProfileAvatarOption {
  const ProfileAvatarOption({
    required this.key,
    required this.icon,
    required this.emoji,
  });

  final String key;
  final IconData icon;
  final String emoji;
}

class ProfileAvatarCatalog {
  static const List<ProfileAvatarOption> options = <ProfileAvatarOption>[
    ProfileAvatarOption(key: 'star', icon: Icons.star_rounded, emoji: '🌟'),
    ProfileAvatarOption(key: 'lion', icon: Icons.pets_rounded, emoji: '🦁'),
    ProfileAvatarOption(
      key: 'fox',
      icon: Icons.cruelty_free_rounded,
      emoji: '🦊',
    ),
    ProfileAvatarOption(
      key: 'bird',
      icon: Icons.flutter_dash_rounded,
      emoji: '🐦',
    ),
    ProfileAvatarOption(key: 'cat', icon: Icons.face_rounded, emoji: '🐱'),
    ProfileAvatarOption(
      key: 'bear',
      icon: Icons.emoji_nature_rounded,
      emoji: '🐻',
    ),
  ];

  static ProfileAvatarOption byKey(String avatarKey) {
    return options.cast<ProfileAvatarOption?>().firstWhere(
          (option) => option?.key == avatarKey,
          orElse: () => options.first,
        ) ??
        options.first;
  }

  static IconData iconForKey(String avatarKey) => byKey(avatarKey).icon;

  static String emojiForKey(String avatarKey) => byKey(avatarKey).emoji;
}
