import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:real_life_rpg/utils/constants.dart';
import '../../features/leaderboard/models/leaderboard_user.dart';
import '../../Services/Challenge/challenge_service.dart';
import '../../models/challenge_match.dart';
import '../../Services/Leaderboard/challenge_rank_service.dart';
import '../../Services/Notifications/enhanced_notification_service.dart';

// ─── ROOT SCREEN ─────────────────────────────────────────────────────────────

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _svc = ChallengeService();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late final Stream<int> _pendingCount;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pendingCount = _svc
        .streamIncomingRequests()
        .map((snap) => snap.docs.length)
        .handleError((_) => 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String? get _myUid => _auth.currentUser?.uid;

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationSheet(svc: _svc),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF5F3FF),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [_buildAppBar()],
        body: TabBarView(
          controller: _tabController,
          children: [
            _SocialTab(svc: _svc, myUid: _myUid, firestore: _firestore),
            _ChallengesTab(svc: _svc, myUid: _myUid),
            _RanksTab(svc: _svc, myUid: _myUid),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.primaryPurple,
      actions: [
        StreamBuilder<int>(
          stream: _pendingCount,
          builder: (ctx, snap) {
            final count = snap.data ?? 0;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 26),
                  onPressed: _showNotifications,
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                          color: Color(0xFFFF4757),
                          shape: BoxShape.circle),
                      child: Center(
                        child: Text('$count',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF9458F7), Color(0xFF4C1D95)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(children: [
                    Text('🏆', style: TextStyle(fontSize: 26)),
                    SizedBox(width: 10),
                    Text('Leaderboard',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ]),
                  SizedBox(height: 4),
                  Text('Connect · Challenge · Compete',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.primaryPurple,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            isScrollable: false,
            enableFeedback: true,
            tabs: [
              Tab(
                icon: Container(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: const Icon(Icons.people_alt_outlined, size: 20),
                ),
                text: 'Social',
                height: 52,
              ),
              Tab(
                icon: Container(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: const Icon(Icons.sports_kabaddi, size: 20),
                ),
                text: 'Challenges',
                height: 52,
              ),
              Tab(
                icon: Container(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: const Icon(Icons.leaderboard, size: 20),
                ),
                text: 'Ranks',
                height: 52,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── NOTIFICATION BOTTOM SHEET ────────────────────────────────────────────────

class _NotificationSheet extends StatelessWidget {
  final ChallengeService svc;
  const _NotificationSheet({required this.svc});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Friend Requests',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: svc.streamIncomingRequests(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: _PurpleLoader());
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const _EmptyState(
                      icon: Icons.notifications_none,
                      message: 'No pending requests');
                }
                // Sort by sentAt in memory
                final sorted = List.of(docs)..sort((a, b) {
                  final ta = (a.data() as Map)['sentAt'] as Timestamp?;
                  final tb = (b.data() as Map)['sentAt'] as Timestamp?;
                  if (ta == null) return 1;
                  if (tb == null) return -1;
                  return tb.compareTo(ta);
                });
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sorted.length,
                  itemBuilder: (ctx, i) {
                    final doc = sorted[i];
                    final data = doc.data() as Map<String, dynamic>;
                    return _RequestTile(
                      requestId: doc.id,
                      fromUid: data['fromUserId'] ?? '',
                      fromUsername: data['fromUsername'] ?? 'Unknown',
                      svc: svc,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestTile extends StatefulWidget {
  final String requestId;
  final String fromUid;
  final String fromUsername;
  final ChallengeService svc;
  const _RequestTile(
      {required this.requestId,
      required this.fromUid,
      required this.fromUsername,
      required this.svc});

  @override
  State<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<_RequestTile> {
  bool _loading = false;

  Future<void> _respond(bool accept) async {
    setState(() => _loading = true);
    if (accept) {
      await widget.svc.acceptFriendRequest(widget.requestId, widget.fromUid);
    } else {
      await widget.svc.declineFriendRequest(widget.requestId);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: const Color(0xFFF8F5FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.15))),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryPurple,
            child: Text(
                widget.fromUsername.isNotEmpty
                    ? widget.fromUsername[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.fromUsername,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const Text('wants to be your friend',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (_loading)
            const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
          else ...[
            _iconBtn(
                icon: Icons.check,
                color: AppColors.accentGreen,
                bg: const Color(0xFFE8FFF5),
                onTap: () => _respond(true)),
            const SizedBox(width: 8),
            _iconBtn(
                icon: Icons.close,
                color: Colors.grey.shade600,
                bg: Colors.grey.shade100,
                onTap: () => _respond(false)),
          ],
        ],
      ),
    );
  }

  Widget _iconBtn(
      {required IconData icon,
      required Color color,
      required Color bg,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ─── SOCIAL TAB ───────────────────────────────────────────────────────────────

class _SocialTab extends StatefulWidget {
  final ChallengeService svc;
  final String? myUid;
  final FirebaseFirestore firestore;
  const _SocialTab(
      {required this.svc, required this.myUid, required this.firestore});
  @override
  State<_SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends State<_SocialTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  Set<String> _followingUids = {};
  Set<String> _outgoingUids = {};
  // fromUid → requestId (for "Accept" button on their card)
  Map<String, String> _incomingReqIds = {};

  final _subs = <StreamSubscription>[];

  @override
  void initState() {
    super.initState();
    if (widget.myUid != null) {
      _subs.add(widget.firestore
          .collection('following')
          .doc(widget.myUid)
          .snapshots()
          .listen((doc) {
        if (!mounted) return;
        setState(() => _followingUids =
            Set<String>.from(doc.data()?['uids'] ?? []));
      }));
      _subs.add(widget.svc.streamOutgoingRequests().listen((snap) {
        if (!mounted) return;
        setState(() => _outgoingUids = snap.docs
            .map((d) => (d.data() as Map)['toUserId'] as String)
            .toSet());
      }));
      _subs.add(widget.svc.streamIncomingRequests().listen((snap) {
        if (!mounted) return;
        setState(() => _incomingReqIds = {
          for (final d in snap.docs)
            (d.data() as Map)['fromUserId'] as String: d.id,
        });
      }));
    }
  }

  @override
  void dispose() {
    for (final s in _subs) { s.cancel(); }
    _searchCtrl.dispose();
    super.dispose();
  }

  _RelState _relState(String uid) {
    if (_followingUids.contains(uid)) return _RelState.friends;
    if (_incomingReqIds.containsKey(uid)) return _RelState.received;
    if (_outgoingUids.contains(uid)) return _RelState.requested;
    return _RelState.none;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ]),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v.trim()),
            decoration: InputDecoration(
              hintText: 'Search players...',
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon:
                  Icon(Icons.search, color: AppColors.primaryPurple),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: widget.svc.streamAllUsers(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: _PurpleLoader());
            }
            var docs = (snap.data?.docs ?? [])
                .where((d) => d.id != widget.myUid)
                .toList();
            if (_query.isNotEmpty) {
              docs = docs.where((d) {
                final name = ((d.data() as Map)['username'] ?? '')
                    .toString()
                    .toLowerCase();
                return name.contains(_query.toLowerCase());
              }).toList();
            }
            if (docs.isEmpty) {
              return const _EmptyState(
                  icon: Icons.people_outline,
                  message: 'No players found');
            }
            return ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: docs.length,
              itemBuilder: (ctx, i) {
                final doc = docs[i];
                final uid = doc.id;
                final user = LeaderboardUser.fromFirestore(doc);
                final charClass =
                    CharacterClass.fromString(user.characterClass);
                final rel = _relState(uid);
                return _SocialCard(
                  user: user,
                  charClass: charClass,
                  rel: rel,
                  onAdd: () => widget.svc.sendFriendRequest(uid),
                  onAccept: () async {
                    final reqId = _incomingReqIds[uid];
                    if (reqId != null) {
                      await widget.svc
                          .acceptFriendRequest(reqId, uid);
                    }
                  },
                  onRemove: () => widget.svc.unfollowUser(uid),
                );
              },
            );
          },
        ),
      ),
    ]);
  }
}

enum _RelState { none, requested, received, friends }

class _SocialCard extends StatelessWidget {
  final LeaderboardUser user;
  final CharacterClass charClass;
  final _RelState rel;
  final VoidCallback onAdd;
  final VoidCallback onAccept;
  final VoidCallback onRemove;
  const _SocialCard(
      {required this.user,
      required this.charClass,
      required this.rel,
      required this.onAdd,
      required this.onAccept,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(children: [
        Stack(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Color(charClass.gradientColors.first),
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(charClass.icon,
                    style: const TextStyle(fontSize: 22))
                : null,
          ),
          if (user.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
              ),
            ),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.username,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 3),
              Row(children: [
                Text('${charClass.icon} Lvl ${user.level}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(width: 10),
                Text('🔥 ${user.streak}d',
                    style: const TextStyle(fontSize: 12)),
              ]),
            ],
          ),
        ),
        _relButton(),
      ]),
    );
  }

  Widget _relButton() {
    switch (rel) {
      case _RelState.friends:
        return _Chip(
            label: 'Friends ✓',
            bg: const Color(0xFFE8FFF5),
            textColor: AppColors.accentGreen,
            onTap: onRemove);
      case _RelState.requested:
        return _Chip(
            label: 'Requested',
            bg: Colors.grey.shade100,
            textColor: Colors.grey.shade500,
            onTap: null);
      case _RelState.received:
        return _Chip(
            label: 'Accept ✓',
            bg: const Color(0xFFFFF3E0),
            textColor: const Color(0xFFE65100),
            onTap: onAccept);
      case _RelState.none:
        return _Chip(
            label: '+ Add',
            bg: AppColors.primaryPurple,
            textColor: Colors.white,
            onTap: onAdd,
            gradient: const LinearGradient(
                colors: [Color(0xFF9458F7), Color(0xFF4C1D95)]));
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;
  final VoidCallback? onTap;
  final Gradient? gradient;
  const _Chip(
      {required this.label,
      required this.bg,
      required this.textColor,
      required this.onTap,
      this.gradient});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: gradient == null ? bg : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor)),
      ),
    );
  }
}

// ─── CHALLENGES TAB ───────────────────────────────────────────────────────────

class _ChallengesTab extends StatefulWidget {
  final ChallengeService svc;
  final String? myUid;
  const _ChallengesTab({required this.svc, required this.myUid});
  @override
  State<_ChallengesTab> createState() => _ChallengesTabState();
}

class _ChallengesTabState extends State<_ChallengesTab> {
  late final Stream<List<ChallengeMatch>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = widget.svc.getChallengesStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChallengeMatch>>(
      stream: _stream,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: _PurpleLoader());
        }
        final challenges = snap.data ?? [];
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: widget.svc.streamIncomingChallengeInvites(),
          builder: (ctx, inviteSnap) {
            final inviteDocs = inviteSnap.data?.docs ?? const [];

            if (challenges.isEmpty && inviteDocs.isEmpty) {
              return const _EmptyState(
                icon: Icons.sports_kabaddi,
                message: 'No challenges yet.\nAdd friends or create a quest!',
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              children: [
                ...inviteDocs.map((d) {
                  final data = d.data();
                  final from = (data['fromUsername'] ?? 'Unknown').toString();
                  final challengeId = (data['challengeId'] ?? '').toString();
                  if (challengeId.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4EEFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mark_email_unread, color: AppColors.primaryPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('$from invited you to a challenge'),
                        ),
                        TextButton(
                          onPressed: () => widget.svc.acceptChallengeInvite(
                            inviteId: d.id,
                            challengeId: challengeId,
                          ),
                          child: const Text('Join'),
                        ),
                        TextButton(
                          onPressed: () => widget.svc.declineChallengeInvite(d.id),
                          child: const Text('Decline'),
                        ),
                      ],
                    ),
                  );
                }),
                ...challenges.map((c) => _ChallengeCard(
                      challenge: c,
                      myUid: widget.myUid,
                      svc: widget.svc,
                    )),
              ],
            );
          },
        );
      },
    );
  }
}

class _ChallengeCard extends StatefulWidget {
  final ChallengeMatch challenge;
  final String? myUid;
  final ChallengeService svc;
  const _ChallengeCard(
      {required this.challenge, required this.myUid, required this.svc});
  @override
  State<_ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<_ChallengeCard> {
  bool _expanded = false;
  bool _joining = false;
  bool _completing = false;
  bool _isJoined = false; // Track joined state locally for immediate UI update
  List<String> _participants = []; // Track participants locally
  bool _inviting = false;

  @override
  void initState() {
    super.initState();
    _participants = List<String>.from(widget.challenge.participantIds);
    _isJoined = _participants.contains(widget.myUid);
  }

  @override
  void didUpdateWidget(_ChallengeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state when widget data changes
    final participants = List<String>.from(widget.challenge.participantIds);
    if (participants.length != _participants.length) {
      setState(() {
        _participants = participants;
        _isJoined = _participants.contains(widget.myUid);
      });
    }
  }

  Color _diffColor(ChallengeTargetType t) {
    switch (t) {
      case ChallengeTargetType.steps:
        return AppColors.primaryPurple;
      case ChallengeTargetType.questCompletion:
        return AppColors.accentMagenta;
      case ChallengeTargetType.xpEarned:
        return AppColors.highlightGold;
      case ChallengeTargetType.stationaryMinutes:
        return AppColors.accentGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    final id = c.id;
    final isOwn = c.createdBy == widget.myUid;
    final diffColor = _diffColor(c.targetType);
    final isEnded = c.isEnded || !c.isActive;
    // Use local state for immediate UI updates
    final isJoined = _isJoined;
    final participants = _participants;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: diffColor.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient top bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                diffColor,
                diffColor.withValues(alpha: 0.4)
              ]),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + difficulty
                Row(children: [
                  Expanded(
                    child: Text(c.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1A1A2E))),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: diffColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                        c.targetType.asString.toUpperCase(),
                        style: TextStyle(
                            color: diffColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                  ),
                ]),
                const SizedBox(height: 6),
                // Rewards
                Row(children: [
                  Text('👤 ${c.createdByName}  ',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                  Text('🎯 Target ${c.targetValue.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12)),
                ]),
                const SizedBox(height: 12),
                // Action buttons
                Row(children: [
                  Expanded(
                    child: isEnded
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Ended',
                                style: TextStyle(
                                  color: AppColors.textGray,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        : _joining
                            ? const Center(child: _PurpleLoader())
                            : isJoined
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F3FF),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      border: Border.all(
                                        color: diffColor.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Joined',
                                        style: TextStyle(
                                          color: AppColors.primaryPurple,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () async {
                                      setState(() => _joining = true);
                                      try {
                                        await widget.svc.joinChallenge(id);
                                        if (!mounted) return;
                                        setState(() {
                                          _joining = false;
                                          _isJoined = true;
                                          if (widget.myUid != null &&
                                              !_participants.contains(
                                                  widget.myUid)) {
                                            _participants.add(widget.myUid!);
                                          }
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Challenge joined! Good luck!'),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } catch (e) {
                                        if (!mounted) return;
                                        setState(() => _joining = false);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Failed to join challenge: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    child: _actionBox(
                                      icon: Icons.sports_kabaddi,
                                      label: 'Join Challenge',
                                      color: AppColors.primaryPurple,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF9458F7),
                                          Color(0xFF4C1D95),
                                        ],
                                      ),
                                    ),
                                  ),
                  ),
                  const SizedBox(width: 10),
                  if (isOwn && !isEnded)
                    GestureDetector(
                      onTap: _inviting ? null : () => _showInviteDialog(context, id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _inviting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.person_add_alt_1,
                                size: 15, color: AppColors.primaryPurple),
                      ),
                    ),
                  if (isOwn && !isEnded) const SizedBox(width: 10),
                  // Expand progress button
                  GestureDetector(
                    onTap: () =>
                        setState(() => _expanded = !_expanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        const Icon(Icons.bar_chart,
                            size: 15, color: AppColors.primaryPurple),
                        const SizedBox(width: 4),
                        Text('${participants.length}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryPurple,
                                fontSize: 13)),
                        Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppColors.primaryPurple),
                      ]),
                    ),
                  ),
                ]),
                // Progress section (expandable, real-time)
                if (_expanded)
                  _ProgressSection(
                    challengeId: id,
                    svc: widget.svc,
                    targetValue: c.targetValue,
                    targetType: c.targetType,
                    ended: isEnded,
                  ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBox(
      {required IconData icon,
      required String label,
      required Color color,
      Gradient? gradient}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: gradient == null ? color.withValues(alpha: 0.1) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: gradient != null ? Colors.white : color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: gradient != null ? Colors.white : color)),
        ],
      ),
    );
  }

  Future<void> _showInviteDialog(BuildContext context, String challengeId) async {
    final myUid = widget.myUid;
    if (myUid == null) return;

    final followingSnap = await FirebaseFirestore.instance
        .collection('following')
        .doc(myUid)
        .get();
    final following = List<String>.from(
      (followingSnap.data() ?? <String, dynamic>{})['uids'] ?? const [],
    );
    if (following.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No friends to invite yet.')),
      );
      return;
    }

    final usersSnap = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: following.take(10).toList())
        .get();

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(12),
        children: usersSnap.docs.map((u) {
          final uname = (u.data()['username'] ?? 'Unknown').toString();
          return ListTile(
            leading: CircleAvatar(child: Text(uname.isEmpty ? '?' : uname[0].toUpperCase())),
            title: Text(uname),
            trailing: TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _inviting = true);
                await widget.svc.inviteUserToChallenge(
                  challengeId: challengeId,
                  targetUid: u.id,
                );
                if (!mounted) return;
                setState(() => _inviting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invitation sent to $uname')),
                );
              },
              child: const Text('Invite'),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final String challengeId;
  final ChallengeTargetType targetType;
  final double targetValue;
  final bool ended;
  final ChallengeService svc;
  const _ProgressSection({
    required this.challengeId,
    required this.targetType,
    required this.targetValue,
    required this.ended,
    required this.svc,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChallengeParticipant>>(
      stream: svc.getChallengeParticipantsStream(challengeId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: _PurpleLoader()),
          );
        }
        final participants = snap.data ?? const [];
        if (participants.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No participants yet.',
                style: TextStyle(color: Colors.grey)),
          );
        }
        final denom = targetValue <= 0 ? 1.0 : targetValue;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 14, bottom: 8),
              child: Text('Live Progress',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1A1A2E))),
            ),
            ...participants.map((p) {
              final isCompleted = p.isCompleted;
              final rank = p.rank;
              final percent = (p.progress / denom).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Text(
                    isCompleted
                        ? (rank == 1
                            ? '🥇'
                            : rank == 2
                                ? '🥈'
                                : rank == 3
                                    ? '🥉'
                                    : '✅')
                        : '⏳',
                    style: TextStyle(
                      fontSize: 16,
                      color: isCompleted ? AppColors.accentGreen : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(p.username,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          if (isCompleted) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppColors.accentGreen
                                      .withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(6)),
                              child: Text(
                                ended && rank != null ? 'Done #$rank' : 'Done',
                                  style: TextStyle(
                                      color: AppColors.accentGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ]
                        ]),
                        const SizedBox(height: 3),
                        LinearProgressIndicator(
                          value: isCompleted ? 1.0 : percent,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted
                                  ? AppColors.accentGreen
                                  : AppColors.primaryPurple),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 5,
                        ),
                      ],
                    ),
                  ),
                ]),
              );
            }),
          ],
        );
      },
    );
  }
}

// ─── RANKS TAB ────────────────────────────────────────────────────────────────

class _RanksTab extends StatefulWidget {
  final ChallengeService svc;
  final String? myUid;
  const _RanksTab({required this.svc, required this.myUid});
  @override
  State<_RanksTab> createState() => _RanksTabState();
}

class _RanksTabState extends State<_RanksTab> {
  final ChallengeRankService _rankService = ChallengeRankService();
  final EnhancedNotificationService _notificationService =
      EnhancedNotificationService();

  Timer? _timer;
  DateTime _now = DateTime.now();

  // Previous snapshot for detecting rank movement + completions.
  int? _prevMyRank;
  final Map<String, bool> _prevCompleted = {};

  DateTime _lastNotificationAt =
      DateTime.fromMillisecondsSinceEpoch(0);
  bool _snapshotInitialized = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _canNotify() {
    return DateTime.now().difference(_lastNotificationAt) >
        const Duration(seconds: 8);
  }

  void _maybeNotify(List<ChallengeRankEntry> entries) {
    final myUid = widget.myUid;
    if (myUid == null) return;
    ChallengeRankEntry? myEntry;
    for (final e in entries) {
      if (e.userId == myUid) {
        myEntry = e;
        break;
      }
    }

    final newMyRank = myEntry?.rank;

    if (!_snapshotInitialized) {
      _prevMyRank = newMyRank;
      for (final e in entries) {
        _prevCompleted[e.userId] = e.isCompleted;
      }
      _snapshotInitialized = true;
      return;
    }

    bool otherCompletedNow = false;
    for (final e in entries) {
      if (e.userId == myUid) continue;
      final prev = _prevCompleted[e.userId] ?? false;
      if (!prev && e.isCompleted) {
        otherCompletedNow = true;
        break;
      }
    }

    final rankImproved = _prevMyRank != null &&
        newMyRank != null &&
        newMyRank < _prevMyRank!;

    if (_canNotify() && (rankImproved || otherCompletedNow)) {
      final title = rankImproved ? 'Rank Updated!' : 'Challenge Completed!';
      final body = rankImproved
          ? 'You improved to #${newMyRank!}.'
          : 'A player finished the challenge! Check the ranking.';

      unawaited(_notificationService.showNotification(
        title: title,
        body: body,
        type: 'rank_movement',
        data: {
          'challengeType': 'challenge',
        },
      ));
      _lastNotificationAt = DateTime.now();
    }

    // Update snapshot after notification decisions.
    _prevMyRank = newMyRank;
    for (final e in entries) {
      _prevCompleted[e.userId] = e.isCompleted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = widget.myUid;
    if (myUid == null) {
      return const _EmptyState(
        icon: Icons.leaderboard_outlined,
        message: 'Login to see challenge ranks.',
      );
    }

    final activeChallengesStream = FirebaseFirestore.instance
        .collection('challenges')
        .where('participantIds', arrayContains: myUid)
        .where('isActive', isEqualTo: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: activeChallengesStream,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: _PurpleLoader());
        }

        final matches = snap.data?.docs
                .map((d) => ChallengeMatch.fromFirestore(
                      d.id,
                      d,
                    ))
                .toList() ??
            [];

        final activeNow = matches.where((m) {
          final started = !m.startAt.isAfter(_now);
          final notEnded = !m.endAt.isBefore(_now);
          return started && notEnded && m.isActive;
        }).toList()
          ..sort((a, b) => a.endAt.compareTo(b.endAt));

        if (activeNow.isEmpty) {
          return const _EmptyState(
            icon: Icons.leaderboard_outlined,
            message: 'No active challenges right now.',
          );
        }

        final challenge = activeNow.first;

        return CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('LIVE CHALLENGE RANKS',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1A1A2E))),
                      const Spacer(),
                      Icon(Icons.refresh,
                          size: 14, color: Colors.grey.shade400),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A1A2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ends in: ${_formatRemaining(challenge.endAt.difference(_now))}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            sliver: StreamBuilder<List<ChallengeRankEntry>>(
              stream: _rankService.streamChallengeRankEntries(
                challengeId: challenge.id,
                targetValue: challenge.targetValue,
                minUpdateInterval: const Duration(seconds: 1),
              ),
              builder: (ctx, rankSnap) {
                if (rankSnap.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: _PurpleLoader()),
                    ),
                  );
                }

                final entries = rankSnap.data ?? const [];
                if (entries.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No participants yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                // Trigger notifications on rank updates.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _maybeNotify(entries);
                });

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i >= entries.length) return null;
                      final e = entries[i];
                      final isMe = e.userId == myUid;
                      return _ChallengeRankCard(entry: e, isMe: isMe);
                    },
                    childCount: entries.length,
                  ),
                );
              },
            ),
          ),
        ]);
      },
    );
  }
}

String _formatRemaining(Duration d) {
  if (d.isNegative) return 'Expired';
  final days = d.inDays;
  final hours = d.inHours % 24;
  final minutes = d.inMinutes % 60;
  if (days > 0) return '${days}d ${hours}h';
  if (hours > 0) return '${hours}h ${minutes}m';
  return '${minutes}m';
}

class _ChallengeRankCard extends StatelessWidget {
  final ChallengeRankEntry entry;
  final bool isMe;
  const _ChallengeRankCard({required this.entry, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFF5F0FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? Border.all(color: AppColors.primaryPurple, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${entry.rank}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: entry.rank <= 10 ? AppColors.primaryPurple : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1A1A2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('🔥 ${entry.streak}d', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 10),
                    Text('⭐ ${entry.currentXP} XP',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Progress: ${entry.progress.toStringAsFixed(0)} / ${entry.targetValue.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                if (entry.isCompleted) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  const _Podium({required this.users});

  @override
  Widget build(BuildContext context) {
    // order: 2nd left, 1st center, 3rd right
    final order = [users[1], users[0], users[2]];
    final heights = [80.0, 110.0, 60.0];
    final badges = ['🥈', '🥇', '🥉'];
    final ranks = [2, 1, 3];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E0A4B), Color(0xFF3A1080)]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(children: [
        const Text('🏆 TODAY\'S TOP',
            style: TextStyle(
                color: Colors.white60,
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (i) {
            final u = order[i];
            final charClass =
                CharacterClass.fromString(u['characterClass'] ?? 'warrior');
            final daily = u['dailyChallengesCompleted'] as int? ?? 0;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(badges[i], style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                CircleAvatar(
                  radius: ranks[i] == 1 ? 28 : 20,
                  backgroundColor: Color(charClass.gradientColors.first),
                  child: Text(charClass.icon,
                      style: TextStyle(
                          fontSize: ranks[i] == 1 ? 24 : 16)),
                ),
                const SizedBox(height: 6),
                Text(u['username'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                    overflow: TextOverflow.ellipsis),
                Text('$daily done',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 11)),
                const SizedBox(height: 6),
                Container(
                  width: 78,
                  height: heights[i],
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: ranks[i] == 1
                            ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                            : ranks[i] == 2
                                ? [const Color(0xFFBDC3C7), const Color(0xFF95A5A6)]
                                : [const Color(0xFFE67E22), const Color(0xFFD35400)]),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text('#${ranks[i]}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
              ],
            );
          }),
        ),
      ]),
    );
  }
}

class _RankCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final int rank;
  final bool isMe;
  const _RankCard(
      {required this.user, required this.rank, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final charClass =
        CharacterClass.fromString(user['characterClass'] ?? 'warrior');
    final daily = user['dailyChallengesCompleted'] as int? ?? 0;
    final streak = user['streak'] as int? ?? 0;
    final xp = user['currentXP'] as int? ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFF5F0FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMe
            ? Border.all(color: AppColors.primaryPurple, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(children: [
        SizedBox(
          width: 34,
          child: Text('#$rank',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: rank <= 10
                      ? AppColors.highlightGold
                      : Colors.grey.shade400)),
        ),
        CircleAvatar(
          radius: 21,
          backgroundColor: Color(charClass.gradientColors.first),
          child: Text(charClass.icon,
              style: const TextStyle(fontSize: 17)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Flexible(
                  child: Text(user['username'] ?? 'Unknown',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1A1A2E)),
                      overflow: TextOverflow.ellipsis),
                ),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(6)),
                    child: const Text('YOU',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ]),
              const SizedBox(height: 3),
              Row(children: [
                Text('🔥 ${streak}d  ',
                    style: const TextStyle(fontSize: 12)),
                Text('⭐ $xp XP',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ]),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$daily',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: daily > 0
                        ? AppColors.primaryPurple
                        : Colors.grey.shade300)),
            Text('completed',
                style: TextStyle(
                    fontSize: 10, color: Colors.grey.shade400)),
          ],
        ),
      ]),
    );
  }
}

// ─── SHARED ────────────────────────────────────────────────────────────────────

class _PurpleLoader extends StatelessWidget {
  const _PurpleLoader();
  @override
  Widget build(BuildContext context) => const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
      strokeWidth: 2.5);
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 60, color: Colors.grey.shade300),
      const SizedBox(height: 14),
      Text(message,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.grey.shade400, fontSize: 14, height: 1.6)),
    ]),
  );
}
