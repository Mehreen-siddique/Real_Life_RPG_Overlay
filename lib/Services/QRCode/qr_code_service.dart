import 'package:flutter/material.dart';

/// Data decoded from a QR code scan.
class QRData {
  final String userId;
  final DateTime generatedAt;

  const QRData({required this.userId, required this.generatedAt});

  /// Returns true if the QR code is older than 24 hours.
  bool get isExpired =>
      DateTime.now().difference(generatedAt).inHours > 24;

  /// Parse raw QR string in format "rlrpg:<userId>:<timestamp>".
  static QRData? parse(String raw) {
    try {
      final parts = raw.split(':');
      if (parts.length < 3 || parts[0] != 'rlrpg') return null;
      final userId = parts[1];
      final ts = int.tryParse(parts[2]);
      if (ts == null) return null;
      return QRData(
        userId: userId,
        generatedAt: DateTime.fromMillisecondsSinceEpoch(ts),
      );
    } catch (_) {
      return null;
    }
  }
}

/// User profile data used by the profile screen.
class UserProfile {
  final String userId;
  final String username;
  final String email;
  final int level;
  final int currentXP;
  final int totalQuestsCompleted;
  final int coins;
  final int streak;
  final int rank;
  final DateTime? lastActive;

  const UserProfile({
    required this.userId,
    required this.username,
    required this.email,
    required this.level,
    required this.currentXP,
    required this.totalQuestsCompleted,
    required this.coins,
    required this.streak,
    required this.rank,
    this.lastActive,
  });

  /// Emoji badge based on rank.
  String get rankBadge {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    if (rank <= 10) return '🏆';
    if (rank <= 50) return '⭐';
    return '👤';
  }

  /// Human-readable last active string.
  String get lastActiveText {
    if (lastActive == null) return 'recently';
    final diff = DateTime.now().difference(lastActive!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// XP progress fraction towards next level (0.0–1.0).
  double get progressPercentage {
    final xpForNext = level * 100;
    return (currentXP / xpForNext).clamp(0.0, 1.0);
  }
}

/// Service for generating, parsing, and sharing QR codes.
class QRCodeService {
  static final QRCodeService _instance = QRCodeService._internal();
  static QRCodeService get instance => _instance;
  QRCodeService._internal();

  /// Parse a raw QR string and return [QRData], or null if invalid.
  QRData? parseQRCode(String rawData) => QRData.parse(rawData);

  /// Share QR code — placeholder; integrate with share_plus if needed.
  void shareQRCode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR code sharing coming soon!')),
    );
  }
}

/// Service for resolving a [QRData] to a [UserProfile].
class QRScannerService {
  static final QRScannerService _instance = QRScannerService._internal();
  static QRScannerService get instance => _instance;
  QRScannerService._internal();

  /// Look up a user profile from a scanned [QRData].
  /// Returns null if the user cannot be found.
  Future<UserProfile?> getUserProfileFromQR(QRData qrData) async {
    // Delegate to leaderboard / Firestore lookup — stubbed for now.
    // Replace with actual Firestore fetch when ready.
    debugPrint('[QR_SCANNER] Looking up userId: ${qrData.userId}');
    return null;
  }
}
